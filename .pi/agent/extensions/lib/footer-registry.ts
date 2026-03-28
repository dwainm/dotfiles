/**
 * Footer Registry — Shared state for footer composition
 *
 * WORKAROUND: PI doesn't share module state between extensions.
 * We use globalThis to store the shared registry.
 */

import type { ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { Theme } from "@mariozechner/pi-tui";

export interface FooterPanel {
  lines: string[];
  priority: number; // lower = rendered first (top of footer)
}

export type PanelRenderer = (width: number, theme: Theme, ctx: ExtensionContext) => FooterPanel;

interface PanelEntry {
  key: string;
  renderer: PanelRenderer;
}

// Shared state via globalThis (workaround for PI's isolated module loading)
declare global {
  var __footerRegistry: {
    panels: Map<string, PanelEntry>;
    renderCallback: (() => void) | null;
  };
}

function getRegistry() {
  if (!globalThis.__footerRegistry) {
    globalThis.__footerRegistry = {
      panels: new Map<string, PanelEntry>(),
      renderCallback: null,
    };
  }
  return globalThis.__footerRegistry;
}

export function registerPanel(key: string, renderer: PanelRenderer): void {
  const registry = getRegistry();
  registry.panels.set(key, { key, renderer });
  registry.renderCallback?.();
}

export function unregisterPanel(key: string): void {
  const registry = getRegistry();
  registry.panels.delete(key);
  registry.renderCallback?.();
}

export function getPanels(): PanelEntry[] {
  const registry = getRegistry();
  return Array.from(registry.panels.values());
}

export function setRenderCallback(cb: () => void): void {
  const registry = getRegistry();
  registry.renderCallback = cb;
}

export function requestRender(): void {
  const registry = getRegistry();
  registry.renderCallback?.();
}
