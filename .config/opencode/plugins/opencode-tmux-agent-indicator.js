// opencode tmux window rename plugin.

import { exec } from "node:child_process";

const FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

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

  const stopSpinner = () => { spinnerActive = false; };

  const startSpinner = async () => {
    stopSpinner();
    spinnerActive = true;
    const name = await getOriginalName();
    if (!name) return;
    let idx = 0;
    const tick = async () => {
      if (!spinnerActive) return;
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
        rename(`❓ ${await getOriginalName()}`);
        break;
      case "done":
        stopSpinner();
        rename(`💤 ${await getOriginalName()}`);
        setTimeout(async () => {
          if (lastState !== "done") return;
          stopSpinner();
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
    event: async ({ event }) => {
      if (event.type === "session.status" && event.properties?.status?.type === "busy") {
        await setState("running");
      }
      if (event.type === "session.idle") {
        await setState("done");
      }
    },
  };
};
