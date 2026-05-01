// opencode tmux window rename plugin.
// Shows animated spinner / state emoji in the tmux window tab name.
// Uses rename-window directly, bypassing Catppuccin format strings.
//
// States:
//   running     -> animated braille spinner (background bash loop)
//   needs-input -> "❓ original-name"
//   done        -> "💤 original-name" (restores after 3s)
//   idle/error  -> restores original name

export const TmuxAgentIndicator = async ({ $ }) => {
  const PANE = process.env.TMUX_PANE;
  const IN_TMUX = !!process.env.TMUX;

  let lastState = "off";
  let originalName = null;
  let windowId = null;
  let sessionName = null;

  const tmux = async (args) => {
    if (!IN_TMUX) return;
    try {
      await $`tmux ${args}`.quiet().nothrow();
    } catch {
      // ignore
    }
  };

  const getOriginalName = async () => {
    if (originalName) return originalName;
    if (!windowId) return null;
    const envKey = `TMUX_AGENT_ORIG_NAME_${windowId}`;
    try {
      const result = await $`tmux show-environment -g ${envKey}`.quiet().nothrow();
      const val = result.stdout?.trim() || "";
      if (val && !val.startsWith(envKey)) {
        originalName = val;
        return val;
      }
    } catch { /* ignore */ }

    // Not saved yet — get current name and save it
    try {
      const result = await $`tmux display-message -p -t ${PANE} #{window_name}`.quiet().nothrow();
      let name = result.stdout?.trim() || "";
      // Strip any existing spinner/state prefix
      if (/^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏❓💤💻] /.test(name)) {
        name = name.slice(2);
      }
      originalName = name;
      await tmux(["set-environment", "-g", envKey, name]);
      return name;
    } catch {
      return null;
    }
  };

  const killAnimator = async () => {
    if (!windowId) return;
    const animKey = `TMUX_AGENT_ANIM_${windowId}_PID`;
    try {
      const result = await $`tmux show-environment -g ${animKey}`.quiet().nothrow();
      const pid = (result.stdout?.trim() || "").replace(/^[^=]*=/, "");
      if (pid && !isNaN(Number(pid))) {
        try {
          process.kill(Number(pid), 0); // check if alive
          process.kill(Number(pid), "SIGTERM");
        } catch {
          // already dead
        }
      }
      await tmux(["set-environment", "-gu", animKey]);
    } catch {
      // ignore
    }
  };

  const startAnimator = async () => {
    if (!windowId || !sessionName) return;
    const animKey = `TMUX_AGENT_ANIM_${windowId}_PID`;
    // Check if already running
    try {
      const result = await $`tmux show-environment -g ${animKey}`.quiet().nothrow();
      const pid = (result.stdout?.trim() || "").replace(/^[^=]*=/, "");
      if (pid && !isNaN(Number(pid))) {
        try {
          process.kill(Number(pid), 0);
          return; // already running
        } catch {
          // dead, start new one
        }
      }
    } catch { /* ignore */ }

    const script = `${process.env.HOME}/.config/tmux/scripts/opencode-window-animator.sh`;
    try {
      // nohup so it survives opencode process changes; disown via nohup
      await $`nohup bash ${script} ${windowId} ${sessionName} >/dev/null 2>&1 &`.quiet().nothrow();
    } catch {
      // ignore
    }
  };

  const renameWindow = async (prefix, name) => {
    if (!windowId || !name) return;
    const newName = `${prefix} ${name}`;
    await tmux(["rename-window", "-t", windowId, newName]);
  };

  const restoreOriginalName = async () => {
    const name = await getOriginalName();
    if (name && windowId) {
      await tmux(["rename-window", "-t", windowId, name]);
    }
    await killAnimator();
    // Clear saved name after restoring
    if (windowId) {
      await tmux(["set-environment", "-gu", `TMUX_AGENT_ORIG_NAME_${windowId}`]);
    }
    originalName = null;
  };

  const setState = async (state) => {
    if (state === lastState) return;
    lastState = state;

    if (!IN_TMUX || !PANE) return;

    // Resolve window and session on first call
    if (!windowId) {
      try {
        const wResult = await $`tmux display-message -p -t ${PANE} #{window_id}`.quiet().nothrow();
        windowId = wResult.stdout?.trim() || null;
      } catch { /* ignore */ }
    }
    if (!sessionName) {
      try {
        const sResult = await $`tmux display-message -p -t ${PANE} #{session_name}`.quiet().nothrow();
        sessionName = sResult.stdout?.trim() || null;
      } catch { /* ignore */ }
    }

    switch (state) {
      case "running": {
        const name = await getOriginalName();
        await startAnimator();
        break;
      }
      case "needs-input": {
        await killAnimator();
        const name = await getOriginalName();
        await renameWindow("❓", name);
        break;
      }
      case "done": {
        await killAnimator();
        const name = await getOriginalName();
        await renameWindow("💤", name);
        // Restore original name after 3 seconds
        setTimeout(async () => {
          if (lastState === "done") {
            await restoreOriginalName();
            lastState = "off";
          }
        }, 3000);
        break;
      }
      case "off":
      default: {
        await restoreOriginalName();
        break;
      }
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.status"
          && event.properties.status.type === "busy") {
        await setState("running");
      }

      if (event.type === "permission.updated"
          || event.type === "permission.asked") {
        await setState("needs-input");
      }

      if (event.type === "session.idle") {
        await setState("done");
      }

      if (event.type === "session.error") {
        await setState("done");
      }
    },
    "permission.ask": async () => {
      await setState("needs-input");
    },
    "tool.execute.before": async (input) => {
      if (input.tool === "question") {
        await setState("needs-input");
      }
    },
  };
};
