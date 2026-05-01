// opencode tmux window rename plugin.
// Renames the tmux window tab to show opencode state.

import { execSync } from "node:child_process";

const FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

export const TmuxAgentIndicator = async () => {
  if (!process.env.TMUX) return {};
  const PANE = process.env.TMUX_PANE;
  if (!PANE) return {};

  let lastState = "off";
  let windowId = null;
  let originalName = null;
  let doneTimer = null;
  let spinnerInterval = null;

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
    execSync(`tmux rename-window -t ${windowId} '${text}' 2>/dev/null`, { timeout: 1000 });
  };

  const stopSpinner = () => {
    if (spinnerInterval) { clearInterval(spinnerInterval); spinnerInterval = null; }
  };

  const startSpinner = () => {
    stopSpinner();
    const name = getOriginalName();
    if (!name) return;
    let idx = 0;
    spinnerInterval = setInterval(() => {
      rename(`${FRAMES[idx]} ${name}`);
      idx = (idx + 1) % FRAMES.length;
    }, 120);
  };

  const setState = (state) => {
    if (state === lastState) return;
    lastState = state;
    if (!windowId) windowId = run(`tmux display-message -p -t ${PANE} '#{window_id}'`);

    switch (state) {
      case "running":
        startSpinner();
        break;
      case "needs-input":
        stopSpinner();
        rename(`❓ ${getOriginalName()}`);
        break;
      case "done":
        stopSpinner();
        rename(`💤 ${getOriginalName()}`);
        setTimeout(() => {
          if (lastState !== "done") return;
          stopSpinner();
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
