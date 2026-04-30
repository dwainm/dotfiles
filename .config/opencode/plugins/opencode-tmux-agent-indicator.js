// tmux-agent-indicator plugin for OpenCode.
// Install to ~/.config/opencode/plugins/ or .opencode/plugins/ (project-level).
// Tracks session state and calls agent-state.sh to update tmux pane visuals.

export const TmuxAgentIndicator = async ({ $ }) => {
  const dir = process.env.TMUX_AGENT_INDICATOR_DIR
    || `${process.env.HOME}/.tmux/plugins/tmux-agent-indicator`;
  const script = `${dir}/scripts/agent-state.sh`;

  const PANE = process.env.TMUX_PANE;
  const IN_TMUX = !!process.env.TMUX;

  let lastState = "off";
  let idleAt = 0;

  const setPaneOption = async (val) => {
    if (!IN_TMUX || !PANE) return;
    await $`tmux set-option -p -t ${PANE} @opencode_status ${val}`
      .quiet().nothrow();
  };

  const setState = async (state) => {
    if (state === lastState) return;
    lastState = state;
    try {
      if (state === "running") {
        await $`bash ${script} --agent opencode --state off`;
      }
      await $`bash ${script} --agent opencode --state ${state}`;
      await setPaneOption(state);
    } catch {
      // non-fatal: tmux may not be available
    }
  };

  return {
    event: async ({ event }) => {
      if (event.type === "session.status"
          && event.properties.status.type === "busy") {
        // Guard: don't override done/error if idle fired recently (race condition)
        if (Date.now() - idleAt < 2000) return;
        await setState("running");
      }

      if (event.type === "permission.updated"
          || event.type === "permission.asked") {
        await setState("needs-input");
      }

      if (event.type === "session.idle") {
        idleAt = Date.now();
        await setState("done");
      }

      if (event.type === "session.error") {
        idleAt = Date.now();
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
