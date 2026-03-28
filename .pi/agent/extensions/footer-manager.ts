/**
 * Footer Manager — Owns the footer, composes panels from registry
 *
 * This extension owns setFooter(). Uses a shared registry that other
 * extensions can access via globalThis (workaround for PI's module isolation).
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { getPanels, setRenderCallback, requestRender } from "./lib/footer-registry";

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    if (!ctx.ui) return;

    ctx.ui.setFooter((tui, theme, footerData) => {
      setRenderCallback(() => tui.requestRender());
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: () => {
          unsub();
          setRenderCallback(null);
        },
        invalidate() {},
        render(width: number): string[] {
          const panels = getPanels();
          const lines: string[] = [];

          for (const entry of panels) {
            try {
              const panel = entry.renderer(width, theme, ctx);
              lines.push(...panel.lines);
            } catch (err) {
              console.error(`[Footer] Error in panel ${entry.key}:`, err);
            }
          }

          return lines;
        },
      };
    });
  });
}
