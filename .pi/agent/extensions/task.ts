/**
 * Task Extension — Simple Task Tracking
 *
 * A lightweight task tracking extension. Use tasks to organize and track
 * work without blocking tool execution. Keep AGENTS.md updated as you go.
 *
 * Three-state lifecycle:  idle → inprogress → done
 *
 * UI surfaces:
 * - Footer:  persistent task list with live progress + list title
 * - Widget:  prominent "current task" display (the inprogress task)
 * - Status:  compact summary in the status line
 * - /task:  interactive overlay with full task details
 *
 * Usage: pi -e extensions/task.ts
 */

import { StringEnum } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext, Theme } from "@mariozechner/pi-coding-agent";
import { DynamicBorder } from "@mariozechner/pi-coding-agent";
import { Container, matchesKey, Text, truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { Type } from "@sinclair/typebox";
import { registerPanel, requestRender } from "./footer-registry";

// ── Types ──────────────────────────────────────────────────────────────

type TaskStatus = "idle" | "inprogress" | "done";

interface Task {
	id: number;
	text: string;
	status: TaskStatus;
}

interface TaskDetails {
	action: string;
	tasks: Task[];
	nextId: number;
	listTitle?: string;
	listDescription?: string;
	error?: string;
}

const TaskParams = Type.Object({
	action: StringEnum(["new-list", "add", "toggle", "remove", "update", "list", "clear"] as const),
	text: Type.Optional(Type.String({ description: "Task text (for add/update), or list title (for new-list)" })),
	texts: Type.Optional(Type.Array(Type.String(), { description: "Multiple task texts (for add). Use this to batch-add several tasks at once." })),
	description: Type.Optional(Type.String({ description: "List description (for new-list)" })),
	id: Type.Optional(Type.Number({ description: "Task ID (for toggle/remove/update)" })),
});

// ── Status helpers ─────────────────────────────────────────────────────

const STATUS_ICON: Record<TaskStatus, string> = { idle: "○", inprogress: "●", done: "✓" };
const NEXT_STATUS: Record<TaskStatus, TaskStatus> = { idle: "inprogress", inprogress: "done", done: "idle" };
const STATUS_LABEL: Record<TaskStatus, string> = { idle: "idle", inprogress: "in progress", done: "done" };

// ── /task overlay component ────────────────────────────────────────

class TaskListComponent {
	private tasks: Task[];
	private title: string | undefined;
	private desc: string | undefined;
	private theme: Theme;
	private onClose: () => void;
	private cachedWidth?: number;
	private cachedLines?: string[];

	constructor(tasks: Task[], title: string | undefined, desc: string | undefined, theme: Theme, onClose: () => void) {
		this.tasks = tasks;
		this.title = title;
		this.desc = desc;
		this.theme = theme;
		this.onClose = onClose;
	}

	handleInput(data: string): void {
		if (matchesKey(data, "escape") || matchesKey(data, "ctrl+c")) {
			this.onClose();
		}
	}

	render(width: number): string[] {
		if (this.cachedLines && this.cachedWidth === width) return this.cachedLines;

		const lines: string[] = [];
		const th = this.theme;

		lines.push("");
		const heading = this.title
			? th.fg("accent", ` ${this.title} `)
			: th.fg("accent", " Task ");
		const headingLen = this.title ? this.title.length + 2 : 10;
		lines.push(truncateToWidth(
			th.fg("borderMuted", "─".repeat(3)) + heading +
			th.fg("borderMuted", "─".repeat(Math.max(0, width - 3 - headingLen))),
			width,
		));

		if (this.desc) {
			lines.push(truncateToWidth(`  ${th.fg("muted", this.desc)}`, width));
		}
		lines.push("");

		if (this.tasks.length === 0) {
			lines.push(truncateToWidth(`  ${th.fg("dim", "No tasks yet. Ask the agent to add some!")}`, width));
		} else {
			const done = this.tasks.filter((t) => t.status === "done").length;
			const active = this.tasks.filter((t) => t.status === "inprogress").length;
			const idle = this.tasks.filter((t) => t.status === "idle").length;

			lines.push(truncateToWidth(
				"  " +
				th.fg("success", `${done} done`) + th.fg("dim", "  ") +
				th.fg("accent", `${active} active`) + th.fg("dim", "  ") +
				th.fg("muted", `${idle} idle`),
				width,
			));
			lines.push("");

			for (const task of this.tasks) {
				const icon = task.status === "done"
					? th.fg("success", STATUS_ICON.done)
					: task.status === "inprogress"
						? th.fg("accent", STATUS_ICON.inprogress)
						: th.fg("dim", STATUS_ICON.idle);
				const id = th.fg("accent", `#${task.id}`);
				const text = task.status === "done"
					? th.fg("dim", task.text)
					: task.status === "inprogress"
						? th.fg("success", task.text)
						: th.fg("muted", task.text);
				lines.push(truncateToWidth(`  ${icon} ${id} ${text}`, width));
			}
		}

		lines.push("");
		lines.push(truncateToWidth(`  ${th.fg("dim", "Press Escape to close")}`, width));
		lines.push("");

		this.cachedWidth = width;
		this.cachedLines = lines;
		return lines;
	}

	invalidate(): void {
		this.cachedWidth = undefined;
		this.cachedLines = undefined;
	}
}

// ── Extension entry point ──────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	let tasks: Task[] = [];
	let nextId = 1;
	let listTitle: string | undefined;
	let listDescription: string | undefined;
	let nudgedThisCycle = false;

	// ── Snapshot for details ───────────────────────────────────────────

	const makeDetails = (action: string, error?: string): TaskDetails => ({
		action,
		tasks: [...tasks],
		nextId,
		listTitle,
		listDescription,
		...(error ? { error } : {}),
	});

	// ── UI refresh ─────────────────────────────────────────────────────

	const refreshWidget = (ctx: ExtensionContext) => {
		const current = tasks.find((t) => t.status === "inprogress");

		if (!current) {
			ctx.ui.setWidget("task-current", undefined);
			return;
		}

		ctx.ui.setWidget("task-current", (_tui, theme) => {
			const container = new Container();
			const borderFn = (s: string) => theme.fg("dim", s);

			container.addChild(new Text("", 0, 0));
			container.addChild(new DynamicBorder(borderFn));
			const content = new Text("", 1, 0);
			container.addChild(content);
			container.addChild(new DynamicBorder(borderFn));

			return {
				render(width: number): string[] {
					const cur = tasks.find((t) => t.status === "inprogress");
					if (!cur) return [];

					const line =
						theme.fg("accent", "● ") +
						theme.fg("dim", "WORKING ON  ") +
						theme.fg("accent", `#${cur.id}`) +
						theme.fg("dim", "  ") +
						theme.fg("success", cur.text);

					content.setText(truncateToWidth(line, width - 4));
					return container.render(width);
				},
				invalidate() { container.invalidate(); },
			};
		}, { placement: "belowEditor" });
	};

	// Panel renderer for footer-manager
	const renderFooterPanel = (width: number, theme: Theme, _ctx: ExtensionContext) => {
		const done = tasks.filter((t) => t.status === "done").length;
		const active = tasks.filter((t) => t.status === "inprogress").length;
		const idle = tasks.filter((t) => t.status === "idle").length;
		const total = tasks.length;

		// ── Line 1: list title + progress (left), counts (right) ──
		const titleDisplay = listTitle
			? theme.fg("accent", ` ${listTitle} `)
			: theme.fg("dim", " Task ");

		const l1Left = total === 0
			? titleDisplay + theme.fg("muted", "no tasks")
			: titleDisplay +
				theme.fg("warning", "[") +
				theme.fg("success", `${done}`) +
				theme.fg("dim", "/") +
				theme.fg("success", `${total}`) +
				theme.fg("warning", "]");

		const l1Right = total === 0
			? ""
			: theme.fg("dim", STATUS_ICON.idle + " ") + theme.fg("muted", `${idle}`) +
				theme.fg("dim", "  ") +
				theme.fg("accent", STATUS_ICON.inprogress + " ") + theme.fg("accent", `${active}`) +
				theme.fg("dim", "  ") +
				theme.fg("success", STATUS_ICON.done + " ") + theme.fg("success", `${done}`) +
				theme.fg("dim", " ");

		const pad1 = " ".repeat(Math.max(1, width - visibleWidth(l1Left) - visibleWidth(l1Right)));
		const line1 = truncateToWidth(l1Left + pad1 + l1Right, width, "");

		if (total === 0) return { lines: [line1], priority: 10 };

		// ── Rows: inprogress first, then most recent done, max 5 ──
		const activeTasks = tasks.filter((t) => t.status === "inprogress");
		const doneTasks = tasks.filter((t) => t.status === "done").reverse();
		const visible = [...activeTasks, ...doneTasks].slice(0, 5);
		const remaining = total - visible.length;

		const rows = visible.map((t) => {
			const icon = t.status === "done"
				? theme.fg("success", STATUS_ICON.done)
				: theme.fg("accent", STATUS_ICON.inprogress);
			const text = t.status === "done"
				? theme.fg("dim", t.text)
				: theme.fg("success", t.text);
			return truncateToWidth(` ${icon} ${text}`, width, "");
		});

		if (remaining > 0) {
			rows.push(truncateToWidth(
				` ${theme.fg("dim", `  +${remaining} more`)}`,
				width, "",
			));
		}

		return { lines: [line1, ...rows], priority: 10 };
	};

	const refreshUI = (ctx: ExtensionContext) => {
		if (tasks.length === 0) {
			ctx.ui.setStatus("📋 Task: no tasks", "task");
		} else {
			const remaining = tasks.filter((t) => t.status !== "done").length;
			const label = listTitle ? `📋 ${listTitle}` : "📋 Task";
			ctx.ui.setStatus(`${label}: ${tasks.length} tasks (${remaining} remaining)`, "task");
		}

		refreshWidget(ctx);
		requestRender();
	};

	// ── State reconstruction from session ──────────────────────────────

	const reconstructState = (ctx: ExtensionContext) => {
		tasks = [];
		nextId = 1;
		listTitle = undefined;
		listDescription = undefined;

		for (const entry of ctx.sessionManager.getBranch()) {
			if (entry.type !== "message") continue;
			const msg = entry.message;
			if (msg.role !== "toolResult" || msg.toolName !== "task") continue;

			const details = msg.details as TaskDetails | undefined;
			if (details) {
				tasks = details.tasks;
				nextId = details.nextId;
				listTitle = details.listTitle;
				listDescription = details.listDescription;
			}
		}

		refreshUI(ctx);
	};

	pi.on("session_start", async (_event, ctx) => {
		// Register footer panel
		registerPanel("task", renderFooterPanel);
		reconstructState(ctx);
	});
	pi.on("session_switch", async (_event, ctx) => reconstructState(ctx));
	pi.on("session_fork", async (_event, ctx) => reconstructState(ctx));
	pi.on("session_tree", async (_event, ctx) => reconstructState(ctx));

	// ── Optional nudge on agent_end ─────────────────────────────────────

	pi.on("agent_end", async (_event, _ctx) => {
		const incomplete = tasks.filter((t) => t.status !== "done");
		if (incomplete.length === 0 || nudgedThisCycle) return;

		nudgedThisCycle = true;

		const taskList = incomplete
			.map((t) => `  ${STATUS_ICON[t.status]} #${t.id} [${STATUS_LABEL[t.status]}]: ${t.text}`)
			.join("\n");

		pi.sendMessage(
			{
				customType: "task-nudge",
				content: `⚠️ You have ${incomplete.length} incomplete task(s):\n\n${taskList}\n\nConsider updating AGENTS.md with progress, or mark tasks done with \`task toggle\`.`,
				display: true,
			},
			{ triggerTurn: true },
		);
	});

	pi.on("input", async () => {
		nudgedThisCycle = false;
		return { action: "continue" as const };
	});

	// ── Register task tool ─────────────────────────────────────────────

	pi.registerTool({
		name: "task",
		label: "Task",
		description:
			"Manage your task list. Non-blocking — use for organization, not enforcement. " +
			"Actions: new-list (text=title, description), add (text or texts[] for batch), toggle (id) — cycles idle→inprogress→done, remove (id), update (id + text), list, clear. " +
			"Toggle a task to inprogress when working on it, and done when finished. " +
			"Use new-list to start a themed list. Update AGENTS.md as you go.",
		parameters: TaskParams,

		async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
			switch (params.action) {
				case "new-list": {
					if (!params.text) {
						return {
							content: [{ type: "text" as const, text: "Error: text (title) required for new-list" }],
							details: makeDetails("new-list", "text required"),
						};
					}

					// If a list already exists, confirm before replacing
					if (tasks.length > 0 || listTitle) {
						const confirmed = await ctx.ui.confirm(
							"Start a new list?",
							`This will replace${listTitle ? ` "${listTitle}"` : " the current list"} (${tasks.length} task(s)). Continue?`,
							{ timeout: 30000 },
						);
						if (!confirmed) {
							return {
								content: [{ type: "text" as const, text: "New list cancelled by user." }],
								details: makeDetails("new-list", "cancelled"),
							};
						}
					}

					tasks = [];
					nextId = 1;
					listTitle = params.text;
					listDescription = params.description || undefined;

					const result = {
						content: [{
							type: "text" as const,
							text: `New list: "${listTitle}"${listDescription ? ` — ${listDescription}` : ""}`,
						}],
						details: makeDetails("new-list"),
					};
					refreshUI(ctx);
					return result;
				}

				case "list": {
					const header = listTitle ? `${listTitle}:` : "";
					const result = {
						content: [{
							type: "text" as const,
							text: tasks.length
								? (header ? header + "\n" : "") +
									tasks.map((t) => `[${STATUS_ICON[t.status]}] #${t.id} (${t.status}): ${t.text}`).join("\n")
								: "No tasks defined yet.",
						}],
						details: makeDetails("list"),
					};
					refreshUI(ctx);
					return result;
				}

				case "add": {
					const items = params.texts?.length ? params.texts : params.text ? [params.text] : [];
					if (items.length === 0) {
						return {
							content: [{ type: "text" as const, text: "Error: text or texts required for add" }],
							details: makeDetails("add", "text required"),
						};
					}
					const added: Task[] = [];
					for (const item of items) {
						const t: Task = { id: nextId++, text: item, status: "idle" };
						tasks.push(t);
						added.push(t);
					}
					const msg = added.length === 1
						? `Added task #${added[0].id}: ${added[0].text}`
						: `Added ${added.length} tasks: ${added.map((t) => `#${t.id}`).join(", ")}`;
					const result = {
						content: [{ type: "text" as const, text: msg }],
						details: makeDetails("add"),
					};
					refreshUI(ctx);
					return result;
				}

				case "toggle": {
					// Handle both "1" and "#1" formats
					let taskId = params.id;
					if (typeof taskId === "string" && taskId.startsWith("#")) {
						taskId = parseInt(taskId.slice(1), 10);
					}
					
					if (taskId === undefined || Number.isNaN(taskId)) {
						return {
							content: [{ type: "text" as const, text: "Error: id required for toggle (use: task toggle 1)" }],
							details: makeDetails("toggle", "id required"),
						};
					}
					const task = tasks.find((t) => t.id === taskId);
					if (!task) {
						return {
							content: [{ type: "text" as const, text: `Task #${taskId} not found` }],
							details: makeDetails("toggle", `#${taskId} not found`),
						};
					}
					const prev = task.status;
					task.status = NEXT_STATUS[task.status];

					// Enforce single inprogress — demote any other active task
					const demoted: Task[] = [];
					if (task.status === "inprogress") {
						for (const t of tasks) {
							if (t.id !== task.id && t.status === "inprogress") {
								t.status = "idle";
								demoted.push(t);
							}
						}
					}

					let msg = `Task #${task.id}: ${prev} → ${task.status}`;
					if (demoted.length > 0) {
						msg += `\n(Auto-paused ${demoted.map((t) => `#${t.id}`).join(", ")} → idle. Only one task can be in progress at a time.)`;
					}

					const result = {
						content: [{
							type: "text" as const,
							text: msg,
						}],
						details: makeDetails("toggle"),
					};
					refreshUI(ctx);
					return result;
				}

				case "remove": {
					// Handle both "1" and "#1" formats
					let taskId = params.id;
					if (typeof taskId === "string" && taskId.startsWith("#")) {
						taskId = parseInt(taskId.slice(1), 10);
					}
					
					if (taskId === undefined || Number.isNaN(taskId)) {
						return {
							content: [{ type: "text" as const, text: "Error: id required for remove (use: task remove 1)" }],
							details: makeDetails("remove", "id required"),
						};
					}
					const idx = tasks.findIndex((t) => t.id === taskId);
					if (idx === -1) {
						return {
							content: [{ type: "text" as const, text: `Task #${taskId} not found` }],
							details: makeDetails("remove", `#${taskId} not found`),
						};
					}
					const removed = tasks.splice(idx, 1)[0];
					const result = {
						content: [{ type: "text" as const, text: `Removed task #${removed.id}: ${removed.text}` }],
						details: makeDetails("remove"),
					};
					refreshUI(ctx);
					return result;
				}

				case "update": {
					// Handle both "1" and "#1" formats
					let taskId = params.id;
					if (typeof taskId === "string" && taskId.startsWith("#")) {
						taskId = parseInt(taskId.slice(1), 10);
					}
					
					if (taskId === undefined || Number.isNaN(taskId)) {
						return {
							content: [{ type: "text" as const, text: "Error: id required for update (use: task update 1 \"new text\")" }],
							details: makeDetails("update", "id required"),
						};
					}
					if (!params.text) {
						return {
							content: [{ type: "text" as const, text: "Error: text required for update" }],
							details: makeDetails("update", "text required"),
						};
					}
					const toUpdate = tasks.find((t) => t.id === taskId);
					if (!toUpdate) {
						return {
							content: [{ type: "text" as const, text: `Task #${taskId} not found` }],
							details: makeDetails("update", `#${taskId} not found`),
						};
					}
					const oldText = toUpdate.text;
					toUpdate.text = params.text;
					const result = {
						content: [{ type: "text" as const, text: `Updated #${toUpdate.id}: "${oldText}" → "${toUpdate.text}"` }],
						details: makeDetails("update"),
					};
					refreshUI(ctx);
					return result;
				}

				case "clear": {
					if (tasks.length > 0) {
						const confirmed = await ctx.ui.confirm(
							"Clear task list?",
							`This will remove all ${tasks.length} task(s)${listTitle ? ` from "${listTitle}"` : ""}. Continue?`,
							{ timeout: 30000 },
						);
						if (!confirmed) {
							return {
								content: [{ type: "text" as const, text: "Clear cancelled by user." }],
								details: makeDetails("clear", "cancelled"),
							};
						}
					}

					const count = tasks.length;
					tasks = [];
					nextId = 1;
					listTitle = undefined;
					listDescription = undefined;

					const result = {
						content: [{ type: "text" as const, text: `Cleared ${count} task(s)` }],
						details: makeDetails("clear"),
					};
					refreshUI(ctx);
					return result;
				}

				default:
					return {
						content: [{ type: "text" as const, text: `Unknown action: ${params.action}` }],
						details: makeDetails("list", `unknown action: ${params.action}`),
					};
			}
		},

		renderCall(args, theme) {
			let text = theme.fg("toolTitle", theme.bold("task ")) + theme.fg("muted", args.action);
			if (args.texts?.length) text += ` ${theme.fg("dim", `${args.texts.length} tasks`)}`;
			else if (args.text) text += ` ${theme.fg("dim", `"${args.text}"`)}`;
			if (args.description) text += ` ${theme.fg("dim", `— ${args.description}`)}`;
			if (args.id !== undefined) text += ` ${theme.fg("accent", `#${args.id}`)}`;
			return new Text(text, 0, 0);
		},

		renderResult(result, { expanded }, theme) {
			const details = result.details as TaskDetails | undefined;
			if (!details) {
				const text = result.content[0];
				return new Text(text?.type === "text" ? text.text : "", 0, 0);
			}

			if (details.error) {
				return new Text(theme.fg("error", `Error: ${details.error}`), 0, 0);
			}

			const taskList = details.tasks;

			switch (details.action) {
				case "new-list": {
					let msg = theme.fg("success", "✓ New list ") + theme.fg("accent", `"${details.listTitle}"`);
					if (details.listDescription) {
						msg += theme.fg("dim", ` — ${details.listDescription}`);
					}
					return new Text(msg, 0, 0);
				}

				case "list": {
					if (taskList.length === 0) return new Text(theme.fg("dim", "No tasks"), 0, 0);

					let listText = "";
					if (details.listTitle) {
						listText += theme.fg("accent", details.listTitle) + theme.fg("dim", "  ");
					}
					listText += theme.fg("muted", `${taskList.length} task(s):`);
					const display = expanded ? taskList : taskList.slice(0, 5);
					for (const t of display) {
						const icon = t.status === "done"
							? theme.fg("success", STATUS_ICON.done)
							: t.status === "inprogress"
								? theme.fg("accent", STATUS_ICON.inprogress)
								: theme.fg("dim", STATUS_ICON.idle);
						const itemText = t.status === "done"
							? theme.fg("dim", t.text)
							: t.status === "inprogress"
								? theme.fg("success", t.text)
								: theme.fg("muted", t.text);
						listText += `\n${icon} ${theme.fg("accent", `#${t.id}`)} ${itemText}`;
					}
					if (!expanded && taskList.length > 5) {
						listText += `\n${theme.fg("dim", `... ${taskList.length - 5} more`)}`;
					}
					return new Text(listText, 0, 0);
				}

				case "add": {
					const text = result.content[0];
					const msg = text?.type === "text" ? text.text : "";
					return new Text(theme.fg("success", "✓ ") + theme.fg("muted", msg), 0, 0);
				}

				case "toggle": {
					const text = result.content[0];
					const msg = text?.type === "text" ? text.text : "";
					return new Text(theme.fg("accent", "⟳ ") + theme.fg("muted", msg), 0, 0);
				}

				case "remove": {
					const text = result.content[0];
					const msg = text?.type === "text" ? text.text : "";
					return new Text(theme.fg("warning", "✕ ") + theme.fg("muted", msg), 0, 0);
				}

				case "update": {
					const text = result.content[0];
					const msg = text?.type === "text" ? text.text : "";
					return new Text(theme.fg("success", "✓ ") + theme.fg("muted", msg), 0, 0);
				}

				case "clear":
					return new Text(theme.fg("success", "✓ ") + theme.fg("muted", "Cleared all tasks"), 0, 0);

				default:
					return new Text(theme.fg("dim", "done"), 0, 0);
			}
		},
	});

	// ── /task command ───────────────────────────────────────────────────

	pi.registerCommand("task", {
		description: "Show all tasks on the current branch",
		handler: async (_args, ctx) => {
			if (!ctx.hasUI) {
				ctx.ui.notify("/task requires interactive mode", "error");
				return;
			}

			await ctx.ui.custom<void>((_tui, theme, _kb, done) => {
				return new TaskListComponent(tasks, listTitle, listDescription, theme, () => done());
			});
		},
	});
}
