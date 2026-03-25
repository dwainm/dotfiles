/**
 * Purpose Gate — Forces the engineer to declare intent before working
 *
 * On session start, checks for PURPOSE env var or prompts for intent.
 * A persistent widget shows the purpose for the rest of the session.
 * Press Escape/Ctrl+C to cancel and proceed without a purpose.
 *
 * Usage: pi -e extensions/purpose-gate.ts
 * With env var: PURPOSE="fix login bug" pi -e extensions/purpose-gate.ts
 *
 * Commands:
 *   /purpose Your purpose here  — Set purpose
 *   /purpose                    — Show current purpose
 */

import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import { truncateToWidth } from "@mariozechner/pi-tui";

// synthwave: bgWarm #4a1e6a → rgb(74,30,106)
function bg(s: string): string {
	return `\x1b[48;2;74,30,106m${s}\x1b[49m`;
}

// synthwave: pink #ff7edb
function pink(s: string): string {
	return `\x1b[38;2;255,126,219m${s}\x1b[39m`;
}

// synthwave: cyan #36f9f6
function cyan(s: string): string {
	return `\x1b[38;2;54,249,246m${s}\x1b[39m`;
}

function bold(s: string): string {
	return `\x1b[1m${s}\x1b[22m`;
}

// ── State ─────────────────────────────────────────────────────────────

let purpose: string | undefined;

// ── Helpers ────────────────────────────────────────────────────────────

function setPurposeWidget(ctx: ExtensionContext) {
	ctx.ui.setWidget("purpose", () => {
		return {
			render(width: number): string[] {
				const pad = bg(" ".repeat(width));
				const label = pink(bold("  PURPOSE: "));
				const msg = cyan(bold(purpose!));
				const content = bg(truncateToWidth(label + msg + " ".repeat(width), width, ""));
				return [pad, content, pad];
			},
			invalidate() {},
		};
	});
}

async function askForPurpose(ctx: ExtensionContext) {
	// Check for env var first (try both Deno and process styles)
	let envPurpose: string | undefined;
	try {
		envPurpose = Deno.env.get("PURPOSE");
	} catch {
		// @ts-ignore
		if (typeof process !== "undefined" && process.env) {
			// @ts-ignore
			envPurpose = process.env.PURPOSE;
		}
	}

	if (envPurpose && envPurpose.trim()) {
		purpose = envPurpose.trim();
		setPurposeWidget(ctx);
		return;
	}

	// If no env var, prompt user once
	const answer = await ctx.ui.input(
		"What is the purpose of this agent? (Cancel to proceed without)",
		"e.g. Refactor the auth module to use JWT"
	);

	// User cancelled - allow proceeding without purpose
	if (answer === undefined) {
		purpose = undefined;
		return;
	}

	if (answer && answer.trim()) {
		purpose = answer.trim();
		setPurposeWidget(ctx);
	}
}

// ── Extension Entry Point ──────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
	// ── Event Handlers ────────────────────────────────────────────────────

	pi.on("session_start", async (_event, ctx) => {
		void askForPurpose(ctx);
	});

	pi.on("before_agent_start", async (event) => {
		if (!purpose) return;
		return {
			systemPrompt: event.systemPrompt + `\n\n<purpose>\nYour singular purpose this session: ${purpose}\nStay focused on this goal. If a request drifts from this purpose, gently remind the user.\n</purpose>`,
		};
	});

	// ── Slash Command ─────────────────────────────────────────────────────

	pi.registerCommand("purpose", {
		description: "Set or show the session purpose",
		handler: async (args, ctx) => {
			if (args.trim()) {
				// Set new purpose
				purpose = args.trim();
				setPurposeWidget(ctx);
				ctx.ui.notify(`Purpose set: ${purpose}`, "success");
			} else {
				// Show current purpose
				if (purpose) {
					ctx.ui.notify(`Current purpose: ${purpose}`, "info");
				} else {
					ctx.ui.notify("No purpose set. Use: /purpose Your purpose here", "warning");
				}
			}
		},
	});
}
