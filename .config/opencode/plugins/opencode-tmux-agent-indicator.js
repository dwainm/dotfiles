// opencode tmux window rename plugin.

import { exec } from "node:child_process";

const FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const COLORS = ["#f38ba8","#eba0ac","#fab387","#f9e2af","#a6e3a1","#94e2d5","#89b4fa","#b4befe","#cba6f7","#f5c2e7"];

const sh = (cmd) => new Promise((ok) => {
  exec(cmd, { timeout: 5000 }, () => ok());
});

export const TmuxAgentIndicator = async () => {
  if (!process.env.TMUX) return {};
  const PANE = process.env.TMUX_PANE;
  if (!PANE) return {};

  let lastState = "off";
  let windowId = null;
  let originalName = null;
  let spinnerActive = false;

  const getWindowId = async () => {
    if (windowId) return windowId;
    windowId = await new Promise((ok) => {
      exec(`tmux display-message -p -t ${PANE} '#{window_id}'`, { timeout: 3000 }, (err, stdout) => {
        ok(err ? "" : (stdout || "").trim());
      });
    });
    return windowId;
  };

  const getOriginalName = async () => {
    if (originalName) return originalName;
    const wid = await getWindowId();
    if (!wid) return "";
    const name = await new Promise((ok) => {
      exec(`tmux display-message -p -t ${PANE} '#W'`, { timeout: 3000 }, (err, stdout) => {
        ok(err ? "" : (stdout || "").trim());
      });
    });
    let n = name || "";
    if (/^[⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏❓💤⚡] /.test(n)) n = n.slice(2);
    originalName = n;
    return n;
  };

  const rename = async (text) => {
    const wid = await getWindowId();
    if (!wid) return;
    await sh(`tmux rename-window -t ${wid} "${text}" 2>/dev/null`);
  };

  const resetStyle = async () => {
    const wid = await getWindowId();
    if (!wid) return;
    await sh(`tmux set-window-option -qu ${wid} window-status-style 2>/dev/null`);
    await sh(`tmux set-window-option -qu ${wid} window-status-current-style 2>/dev/null`);
  };

  const stopSpinner = () => { spinnerActive = false; };

  const startSpinner = async () => {
    stopSpinner();
    spinnerActive = true;
    const name = await getOriginalName();
    if (!name) return;
    let idx = 0;
    const tick = async () => {
      if (!spinnerActive) return;
      const wid = await getWindowId();
      if (!wid) return;
      await sh(`tmux set-window-option -qt ${wid} window-status-style "fg=${COLORS[idx]},bold"`);
      await sh(`tmux set-window-option -qt ${wid} window-status-current-style "fg=${COLORS[idx]},bold"`);
      await rename(`${FRAMES[idx]} ${name}`);
      idx = (idx + 1) % FRAMES.length;
      setTimeout(tick, 120);
    };
    tick();
  };

  const setState = async (state) => {
    if (state === lastState) return;
    lastState = state;

    switch (state) {
      case "running":
        await startSpinner();
        break;
      case "needs-input":
        stopSpinner();
        await resetStyle();
        rename(`❓ ${await getOriginalName()}`);
        break;
      case "done":
        stopSpinner();
        await resetStyle();
        rename(`💤 ${await getOriginalName()}`);
        setTimeout(async () => {
          if (lastState !== "done") return;
          stopSpinner();
          await resetStyle();
          rename(originalName || await getOriginalName());
          lastState = "off";
        }, 3000);
        break;
    }
  };

  return {
    "tool.execute.before": async () => {
      await setState("running");
    },
    "permission.ask": async () => {
      await setState("needs-input");
    },
    "tool.execute.before": async (input) => {
      if (input?.tool === "question") await setState("needs-input");
      else await setState("running");
    },
    event: async ({ event }) => {
      if (event.type === "session.status" && event.properties?.status?.type === "busy") {
        await setState("running");
      }
      if (event.type === "permission.asked") {
        await setState("needs-input");
      }
      if (event.type === "session.idle") {
        await setState("done");
      }
    },
  };
};
