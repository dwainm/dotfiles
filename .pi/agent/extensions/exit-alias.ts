import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  // Transform /exit to quit (which is the built-in exit command)
  pi.on("input", async (event, ctx) => {
    const text = event.text?.trim() || "";
    
    // /exit should work like quit
    if (text === "/exit") {
      ctx.ui.notify("Goodbye!", "info");
      ctx.shutdown();
      return { action: "handled" };
    }
    
    return { action: "continue" };
  });
  
  pi.on("session_start", async (_event, ctx) => {
    if (ctx.hasUI) {
      ctx.ui.notify("exit-alias: /exit enabled", "info");
    }
  });
}
