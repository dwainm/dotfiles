/**
 * Tool Counter — Footer panel with model-sensitive costing
 *
 * Shows: model + context meter + tokens in/out + cost + tool tally
 * Registers with footer-manager via footer-registry.
 *
 * Features:
 * - Loads cached pricing from disk instantly at session start
 * - Fetches pricing async in background (non-blocking)
 * - Calculates costs based on actual token usage and model-specific rates
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI, ExtensionContext } from "@mariozechner/pi-coding-agent";
import type { Theme } from "@mariozechner/pi-tui";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { registerPanel, requestRender } from "./footer-registry";
import { dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";

// ── Types ───────────────────────────────────────────────────────────────

interface ModelPricing {
  input: number;
  output: number;
}

interface PricingData {
  models: Record<string, ModelPricing>;
  fetchedAt: number;
}

// ── State ───────────────────────────────────────────────────────────────

const state = {
  counts: {} as Record<string, number>,
  pricing: null as PricingData | null,
  pricingLoading: false,
};

// ── Disk Cache ─────────────────────────────────────────────────────────

const __dirname = dirname(fileURLToPath(import.meta.url));
const CACHE_FILE = `${__dirname}/../.pricing-cache.json`;
const CACHE_TTL = 24 * 60 * 60 * 1000;

function loadPricingCache(): PricingData | null {
  try {
    if (!existsSync(CACHE_FILE)) return null;
    const data = JSON.parse(readFileSync(CACHE_FILE, "utf-8"));
    if (Date.now() - data.fetchedAt < CACHE_TTL) return data;
    return null;
  } catch {
    return null;
  }
}

function savePricingCache(data: PricingData): void {
  try {
    const dir = dirname(CACHE_FILE);
    if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
    writeFileSync(CACHE_FILE, JSON.stringify(data, null, 2));
  } catch {}
}

// ── Helpers ─────────────────────────────────────────────────────────────

async function fetchModelPricing(): Promise<PricingData> {
  try {
    const response = await fetch("https://fireworks.ai/models");
    const html = await response.text();
    const models: Record<string, ModelPricing> = {};

    const modelPattern = /([^$]+?)(?:\$([\d.]+)\/M Input \u2022 \$([\d.]+)\/M Output|\$([\d.]+)\/M Tokens?)/g;
    let match;
    while ((match = modelPattern.exec(html)) !== null) {
      const fullText = match[0];
      const modelIdMatch = fullText.match(/href="https:\/\/fireworks\.ai\/models\/([^"]+)"/);
      if (modelIdMatch) {
        const modelUrl = modelIdMatch[1];
        const modelId = `accounts/${modelUrl.replace("/models/", "/models/")}`;
        if (match[2] && match[3]) {
          models[modelId] = { input: parseFloat(match[2]), output: parseFloat(match[3]) };
        } else if (match[4]) {
          const price = parseFloat(match[4]);
          models[modelId] = { input: price, output: price };
        }
      }
    }

    const fallbacks: Record<string, ModelPricing> = {
      "accounts/fireworks/models/deepseek-v3p2": { input: 0.56, output: 1.68 },
      "accounts/fireworks/models/deepseek-v3p1": { input: 0.56, output: 1.68 },
      "accounts/fireworks/models/kimi-k2-thinking": { input: 0.6, output: 2.5 },
      "accounts/fireworks/models/kimi-k2p5": { input: 0.6, output: 3.0 },
      "accounts/fireworks/models/glm-4p7": { input: 0.6, output: 2.2 },
      "accounts/fireworks/models/glm-5": { input: 1.0, output: 3.2 },
      "accounts/cogito/models/cogito-671b-v2-p1": { input: 1.2, output: 1.2 },
      "accounts/fireworks/models/gpt-oss-120b": { input: 0.15, output: 0.6 },
      "accounts/fireworks/models/gpt-oss-20b": { input: 0.07, output: 0.3 },
      "accounts/fireworks/models/qwen3-8b": { input: 0.2, output: 0.2 },
      "accounts/fireworks/models/minimax-m2p5": { input: 0.3, output: 1.2 },
    };

    for (const [id, p] of Object.entries(fallbacks)) {
      if (!models[id]) models[id] = p;
    }

    return { models, fetchedAt: Date.now() };
  } catch {
    return {
      models: {
        "accounts/fireworks/models/deepseek-v3p2": { input: 0.56, output: 1.68 },
        "accounts/fireworks/models/deepseek-v3p1": { input: 0.56, output: 1.68 },
        "accounts/fireworks/models/kimi-k2-thinking": { input: 0.6, output: 2.5 },
        "accounts/fireworks/models/kimi-k2p5": { input: 0.6, output: 3.0 },
        "accounts/fireworks/models/glm-4p7": { input: 0.6, output: 2.2 },
        "accounts/fireworks/models/glm-5": { input: 1.0, output: 3.2 },
        "accounts/cogito/models/cogito-671b-v2-p1": { input: 1.2, output: 1.2 },
        "accounts/fireworks/models/gpt-oss-120b": { input: 0.15, output: 0.6 },
        "accounts/fireworks/models/gpt-oss-20b": { input: 0.07, output: 0.3 },
        "accounts/fireworks/models/qwen3-8b": { input: 0.2, output: 0.2 },
        "accounts/fireworks/models/minimax-m2p5": { input: 0.3, output: 1.2 },
      },
      fetchedAt: Date.now(),
    };
  }
}

// ── Panel Renderer ─────────────────────────────────────────────────────

function renderPanel(width: number, theme: Theme, ctx: ExtensionContext) {
  // Calculate tokens and cost
  let tokIn = 0;
  let tokOut = 0;
  let cost = 0;

  for (const entry of ctx.sessionManager.getBranch()) {
    if (entry.type === "message" && entry.message.role === "assistant") {
      const m = entry.message as AssistantMessage;
      tokIn += m.usage.input;
      tokOut += m.usage.output;
      if (state.pricing?.models[m.model]) {
        const p = state.pricing.models[m.model];
        cost += (m.usage.input * p.input) / 1_000_000 + (m.usage.output * p.output) / 1_000_000;
      }
    }
  }

  const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
  const fmtCost = (n: number) => (n < 0.01 ? `$${n.toFixed(4)}` : `$${n.toFixed(3)}`);
  const costDisplay = state.pricingLoading ? "$?" : fmtCost(cost);

  const usage = ctx.getContextUsage();
  const pct = usage ? usage.percent : 0;
  const filled = Math.round(pct / 10) || 1;
  const model = ctx.model?.id || "no-model";

  const left =
    theme.fg("dim", ` ${model} `) +
    theme.fg("warning", "[") +
    theme.fg("success", "#".repeat(filled)) +
    theme.fg("dim", "-".repeat(10 - filled)) +
    theme.fg("warning", "]") +
    theme.fg("dim", " ") +
    theme.fg("accent", `${Math.round(pct)}%`);

  const entries = Object.entries(state.counts);
  const toolsDisplay = entries.length === 0
    ? ""
    : entries.map(([name, count]) =>
        theme.fg("accent", name) + theme.fg("dim", ":") + theme.fg("success", `${count}`)
      ).join(theme.fg("dim", " ")) + theme.fg("dim", "  ");

  const right =
    toolsDisplay +
    theme.fg("success", `${fmt(tokIn)}`) +
    theme.fg("dim", " in ") +
    theme.fg("accent", `${fmt(tokOut)}`) +
    theme.fg("dim", " out ") +
    theme.fg("warning", costDisplay) +
    theme.fg("dim", " ");

  const pad = " ".repeat(Math.max(1, width - visibleWidth(left) - visibleWidth(right)));
  const line = truncateToWidth(left + pad + right, width, "");

  return { lines: [line], priority: 0 };
}

// ── Extension Entry Point ───────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    state.counts = {};
    state.pricingLoading = false;

    const cached = loadPricingCache();
    if (cached) state.pricing = cached;

    // Register footer panel
    registerPanel("tool-counter", renderPanel);

    // Fetch async if stale
    const shouldFetch = !state.pricing || Date.now() - state.pricing.fetchedAt > CACHE_TTL;
    if (shouldFetch) {
      state.pricingLoading = true;
      fetchModelPricing().then((data) => {
        state.pricing = data;
        state.pricingLoading = false;
        savePricingCache(data);
        requestRender();
      });
    }
  });

  pi.on("tool_execution_end", async (event) => {
    state.counts[event.toolName] = (state.counts[event.toolName] || 0) + 1;
    requestRender();
  });
}