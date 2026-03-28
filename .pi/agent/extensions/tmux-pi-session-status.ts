/**
 * tmux-pi-session-status — Show what the agent is doing
 *
 * States:
 *   working (tool) = Currently executing: bash, read, edit, web_search, etc.
 *   idle (tool)    = Finished, last tool was: bash, read, edit, etc.
 *
 * Branch naming:
 *   - On main/trunk/master: "PROJECTNAME - Branch" (project in CAPS)
 *   - On other branches: "branch-name | status | project" (normal)
 *
 * Alt-T visibility:
 *   feature-x | working (web_search) | #23 | gesondheid  →  Wait
 *   bug-fix   | idle (edit)          | #24 | gesondheid  →  Check results
 *
 * Usage: pi -e extensions/tmux-pi-session-status.ts
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { execSync } from "node:child_process";

export default function (pi: ExtensionAPI) {
	let currentTool: string | null = null;
	let lastTool: string | null = null;
	let idleTimer: NodeJS.Timeout | null = null;

	function clearIdleTimer() {
		if (idleTimer) {
			clearTimeout(idleTimer);
			idleTimer = null;
		}
	}

	function getProjectName(): string {
		try {
			// Get from cwd (directory name)
			const cwd = process.cwd();
			const dirName = cwd.split('/').pop() || "pi";
			
			// Try to get git repo name if inside a git repo
			try {
				const gitRoot = execSync("git rev-parse --show-toplevel 2>/dev/null", { encoding: "utf-8" }).trim();
				const repoName = gitRoot.split('/').pop() || dirName;
				return repoName;
			} catch {
				return dirName;
			}
		} catch {
			return "pi";
		}
	}

	function isGitRepo(): boolean {
		try {
			execSync("git rev-parse --git-dir 2>/dev/null", { encoding: "utf-8" });
			return true;
		} catch {
			return false;
		}
	}

	function getCurrentBranch(): string {
		try {
			return execSync("git branch --show-current 2>/dev/null", { encoding: "utf-8" }).trim();
		} catch {
			// No git - use directory name
			const cwd = process.cwd();
			return cwd.split('/').pop() || "work";
		}
	}

	function setStatus(status: "working" | "idle", tool: string | null) {
		try {
			if (!process.env.TMUX) return;

			const session = execSync("tmux display-message -p '#S'", { encoding: "utf-8" }).trim();
			const parts = session.split(" | ");
			// Only extract issue if session has 4+ parts (branch | status | issue | project)
			// and the issue part looks like an issue reference (#123 or PROJ-123)
			let issue = "";
			if (parts.length >= 4) {
				const potentialIssue = parts[2];
				if (/^#\d+$/.test(potentialIssue) || /^[A-Z]+-\d+$/.test(potentialIssue)) {
					issue = potentialIssue;
				}
			}
			
			const branch = getCurrentBranch();
			const project = getProjectName();
			const projectCaps = project.toUpperCase();
			const inGit = isGitRepo();

			let title: string;

			if (!inGit) {
				// No git repo - just show project name (clean, no status details)
				title = projectCaps;
			} else if (["main", "trunk", "master"].includes(branch)) {
				// On main/trunk/master: "PROJECTNAME - Branch" (no status, no issue)
				const branchDisplay = branch.charAt(0).toUpperCase() + branch.slice(1);
				title = `${projectCaps} - ${branchDisplay}`;
			} else {
				// On other branches: normal format
				const toolInfo = tool ? ` (${tool})` : "";
				const issuePart = issue ? ` | ${issue}` : "";
				title = `${branch} | ${status}${toolInfo}${issuePart} | ${project}`;
			}

			execSync(`tmux rename-session "${title}" 2>/dev/null || true`);
		} catch {
			// Tmux not ready
		}
	}

	// Tool started → working (show current tool)
	pi.on("tool_start", (event) => {
		currentTool = event.tool_name || "tool";
		clearIdleTimer();
		setStatus("working", currentTool);
	});

	// Tool ended → track last tool, maybe idle
	pi.on("tool_end", () => {
		if (currentTool) {
			lastTool = currentTool;
		}
		currentTool = null;

		// Grace period before idle
		idleTimer = setTimeout(() => {
			setStatus("idle", lastTool);
		}, 2000);
	});

	// Agent completely done → idle (show last tool)
	pi.on("agent_end", () => {
		if (currentTool) {
			lastTool = currentTool;
		}
		currentTool = null;
		clearIdleTimer();

		idleTimer = setTimeout(() => {
			setStatus("idle", lastTool);
		}, 1000);
	});

	// User input → back to working
	pi.on("input", () => {
		clearIdleTimer();
		setStatus("working", lastTool || "processing");
	});
}
