// opencode tmux window rename plugin.
// Uses execSync for reliability, renames tmux window tab on state changes.
//
// States:
//   running     -> animated braille spinner (background bash loop)
//   needs-input -> "❓ original-name"
//   done        -> "💤 original-name" (restores after 3s)
//   idle/error  -> restores original name

import { execSync } from "node:child_process";

export const TmuxAgentIndicator = async () => {
  if (!process.env.TMUX) return {};

  const PANE = process.env.TMUX_PANE;
  if (!PANE) return {};

  let lastState = "off";
  let originalName = null;
  let windowId = null;
  let windowIndex = null;
  let sessionName = null;
  let doneTimer = null;

  const run = (cmd) => {
    try {
      return execSync(cmd, { encoding: "utf-8", timeout: 5000 }).trim();
    } catch {
      return "";
    }
  };

  const getOriginalName = () => {
    if (originalName) return originalName;
    if (!windowId) return null;
    const wi = windowIndex || run(`tmux display-message -p -t ${PANE} '#I'`);
    const envKey = `TMUX_AGENT_ORIG_NAME_WIN${wi}`;
    let val = run(`tmux show-environment -g ${envKey}`);
    if (val) {
      val = val.replace(/^[^=]*=/, "").trim();
      if (val) {
        originalName = val;
        return val;
      }
    }
    // Get current window name, strip any prefix we may have added
    let name = run(`tmux display-message -p -t ${PANE} '#W'`);
    if (/^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏❓💤💻] /.test(name)) name = name.slice(2);
    originalName = name;
    run(`tmux set-environment -g ${envKey} '${name}' >/dev/null 2>&1`);
    return name;
  };

  const killAnimator = () => {
    if (!windowId) return;
    const wi = windowIndex || run(`tmux display-message -p -t ${PANE} '#I'`);
    const animKey = `TMUX_AGENT_ANIM_WIN${wi}_PID`;
    const pid = run(`tmux show-environment -g ${animKey}`).replace(/^[^=]*=/, "");
    if (pid) {
      try { process.kill(Number(pid), "SIGTERM"); } catch {}
    }
    run(`tmux set-environment -gu ${animKey} >/dev/null 2>&1`);
  };

  const startAnimator = () => {
    if (!windowId || !sessionName) return;
    const wi = windowIndex || run(`tmux display-message -p -t ${PANE} '#I'`);
    const animKey = `TMUX_AGENT_ANIM_WIN${wi}_PID`;
    const pid = run(`tmux show-environment -g ${animKey}`).replace(/^[^=]*=/, "");
    if (pid) {
      try { process.kill(Number(pid), 0); return; } catch {}
    }
    const script = `${process.env.HOME}/.config/tmux/scripts/opencode-window-animator.sh`;
    execSync(`nohup bash ${script} ${windowId} ${sessionName} >/dev/null 2>&1 &`, { timeout: 1000 });
  };

  const renameWindow = (prefix, name) => {
    if (!windowId || !name) return;
    execSync(`tmux rename-window -t ${windowId} '${prefix} ${name}'`, { timeout: 1000 });
  };

  const restoreOriginalName = () => {
    const name = originalName;
    if (name && windowId) {
      execSync(`tmux rename-window -t ${windowId} '${name}'`, { timeout: 1000 });
    }
    killAnimator();
    if (windowId) {
      const wi = windowIndex || run(`tmux display-message -p -t ${PANE} '#I'`);
      run(`tmux set-environment -gu TMUX_AGENT_ORIG_NAME_WIN${wi} >/dev/null 2>&1`);
    }
    originalName = null;
  };

  const setState = (state) => {
    if (state === lastState) return;
    lastState = state;

    if (!windowId) windowId = run(`tmux display-message -p -t ${PANE} '#{window_id}'`);
    if (!windowIndex) windowIndex = run(`tmux display-message -p -t ${PANE} '#I'`);
    if (!sessionName) sessionName = run(`tmux display-message -p -t ${PANE} '#S'`);

    // Set env var so animator script knows the state
    run(`tmux set-environment -g TMUX_AGENT_PANE_${PANE}_STATE '${state}' >/dev/null 2>&1`);
    if (state === "done" || state === "needs-input") {
      run(`tmux set-environment -g TMUX_AGENT_PANE_${PANE}_AGENT 'opencode' >/dev/null 2>&1`);
    }

    switch (state) {
      case "running": {
        getOriginalName();
        startAnimator();
        break;
      }
      case "needs-input": {
        killAnimator();
        const name = getOriginalName();
        renameWindow("❓", name);
        break;
      }
      case "done": {
        killAnimator();
        const name = getOriginalName();
        renameWindow("💤", name);
        setTimeout(() => {
          if (lastState === "done") { restoreOriginalName(); lastState = "off"; }
        }, 3000);
        break;
      }
    }
  };

  return {
    "tool.execute.before": () => {
      if (doneTimer) { clearTimeout(doneTimer); doneTimer = null; }
      setState("running");
    },
    "tool.execute.after": () => {
      if (doneTimer) clearTimeout(doneTimer);
      doneTimer = setTimeout(() => {
        doneTimer = null;
        setState("done");
      }, 2000);
    },
    event: ({ event }) => {
      if (event.type === "session.idle") {
        if (doneTimer) { clearTimeout(doneTimer); doneTimer = null; }
        setState("done");
      }
    },
  };
};
