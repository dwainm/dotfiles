// opencode tmux window rename plugin.
// Renames the tmux window tab to show opencode state.

import { execSync } from "node:child_process";

export const TmuxAgentIndicator = async () => {
  if (!process.env.TMUX) return {};
  const PANE = process.env.TMUX_PANE;
  if (!PANE) return {};

  let lastState = "off";
  let windowId = run(`tmux display-message -p -t ${PANE} '#{window_id}'`);
  let originalName = null;
  let doneTimer = null;

  const run = (cmd) => {
    try { return execSync(cmd, { encoding: "utf-8", timeout: 5000 }).trim(); } catch { return ""; }
  };

  const getOriginalName = () => {
    if (originalName) return originalName;
    if (!windowId) return "";
    let name = run(`tmux display-message -p -t ${PANE} '#W'`);
    if (/^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏❓💤] /.test(name)) name = name.slice(2);
    originalName = name;
    return name;
  };

  const rename = (text) => {
    if (!windowId) return;
    execSync(`tmux rename-window -t ${windowId} "${text}" 2>/dev/null`, { timeout: 1000 });
  };

  const setState = (state) => {
    if (state === lastState) return;
    lastState = state;

    switch (state) {
      case "running":
        rename(`⚡ ${getOriginalName()}`);
        break;
      case "needs-input":
        rename(`❓ ${getOriginalName()}`);
        break;
      case "done":
        rename(`💤 ${getOriginalName()}`);
        setTimeout(() => {
          if (lastState !== "done") return;
          rename(originalName || getOriginalName());
          lastState = "off";
        }, 3000);
        break;
    }
  };

  return {
    "tool.execute.before": () => {
      if (doneTimer) { clearTimeout(doneTimer); doneTimer = null; }
      setState("running");
    },
    "tool.execute.after": () => {
      if (doneTimer) clearTimeout(doneTimer);
      doneTimer = setTimeout(() => { doneTimer = null; setState("done"); }, 2000);
    },
    event: ({ event }) => {
      if (event.type === "session.idle") {
        if (doneTimer) { clearTimeout(doneTimer); doneTimer = null; }
        setState("done");
      }
    },
  };
};
