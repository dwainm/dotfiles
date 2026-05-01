// opencode tmux window rename plugin.

import { exec } from "node:child_process";

const sh = (cmd) => new Promise((ok) => {
  exec(cmd, { timeout: 5000 }, () => ok());
});

const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
const BLINK   = ["❓ ", "   "];
const PULSE   = ["💤 ", "   "];

export const TmuxAgentIndicator = async () => {
  if (!process.env.TMUX) return {};
  const PANE = process.env.TMUX_PANE;
  if (!PANE) return {};

  let lastState = "off";
  let windowId = null;
  let originalName = null;
  let animId = 0;

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
    // also strip blink/zzz patterns that might have extra spaces
    n = n.replace(/^[❓💤\s]+ /, "").trim() || n;
    originalName = n;
    return n;
  };

  const rename = async (text) => {
    const wid = await getWindowId();
    if (!wid) return;
    await sh(`tmux rename-window -t ${wid} "${text}" 2>/dev/null`);
  };

  const stopAnim = () => { animId++; };

  const startAnim = async (frames, speed, name) => {
    stopAnim();
    const myId = ++animId;
    if (!name) name = await getOriginalName();
    if (!name) return;
    let idx = 0;
    const tick = async () => {
      if (animId !== myId) return;
      await rename(`${frames[idx]} ${name}`);
      idx = (idx + 1) % frames.length;
      setTimeout(tick, speed);
    };
    tick();
  };

  const setState = async (state) => {
    if (state === lastState) return;
    lastState = state;

    switch (state) {
      case "running":
        await startAnim(SPINNER, 120);
        break;
      case "needs-input":
        await startAnim(BLINK, 500);
        break;
      case "done":
        await startAnim(PULSE, 600);
        break;
    }
  };

  return {
    "tool.execute.before": async (input) => {
      if (input?.tool === "question") await setState("needs-input");
      else await setState("running");
    },
    "permission.ask": async () => {
      await setState("needs-input");
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
      if (event.type === "message.updated" && lastState === "done") {
        await setState("running");
      }
    },
  };
};
