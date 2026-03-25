/**
 * Tool Counter — Rich two-line custom footer with model-sensitive costing
 *
 * Line 1: model + context meter on left, tokens in/out + cost on right
 * Line 2: cwd (branch) on left, tool call tally on right
 *
 * Features:
 * - Loads cached pricing from disk instantly at session start
 * - Fetches pricing async in background (non-blocking)
 * - Calculates costs based on actual token usage and model-specific rates
 * - Updates costs in real-time as tokens are used
 *
 * Commands: none
 * Usage: Automatically loaded via ~/.pi/agent/extensions/
 */

import type { AssistantMessage } from "@mariozechner/pi-ai";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@mariozechner/pi-tui";
import { basename, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";

// ── Types ───────────────────────────────────────────────────────────────

interface ModelPricing {
  input: number; // per million tokens
  output: number; // per million tokens
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
  currentSessionTokens: {
    input: 0,
    output: 0,
    cost: 0,
  },
};

// ── Disk Cache ─────────────────────────────────────────────────────────

const __dirname = dirname(fileURLToPath(import.meta.url));
const CACHE_FILE = `${__dirname}/../.pricing-cache.json`;
const CACHE_TTL = 24 * 60 * 60 * 1000; // 24 hours

function loadPricingCache(): PricingData | null {
  try {
    if (!existsSync(CACHE_FILE)) return null;
    const data = JSON.parse(readFileSync(CACHE_FILE, "utf-8"));
    // Check if cache is still valid
    if (Date.now() - data.fetchedAt < CACHE_TTL) {
      return data;
    }
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
  } catch {
    // Ignore cache write errors
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────

/**
 * Fetches model pricing from Fireworks AI website
 */
async function fetchModelPricing(): Promise<PricingData> {
  try {
    const response = await fetch("https://fireworks.ai/models");
    const html = await response.text();

    const models: Record<string, ModelPricing> = {};

    // Extract model information from the page
    // Look for patterns like: Model Name $0.56/M Input • $1.68/M Output
    const modelPattern =
      /([^$]+?)(?:\$([\d.]+)\/M Input \u2022 \$([\d.]+)\/M Output|\$([\d.]+)\/M Tokens?)/g;

    let match;
    while ((match = modelPattern.exec(html)) !== null) {
      const fullText = match[0];
      const modelIdMatch = fullText.match(/href="https:\/\/fireworks\.ai\/models\/([^"]+)"/);

      if (modelIdMatch) {
        // Convert URL path to model ID format
        const modelUrl = modelIdMatch[1];
        const modelId = `accounts/${modelUrl.replace("/models/", "/models/")}`;

        // Extract pricing
        if (match[2] && match[3]) {
          // Has separate input/output prices
          models[modelId] = {
            input: parseFloat(match[2]),
            output: parseFloat(match[3]),
          };
        } else if (match[4]) {
          // Single price for both (rare)
          const price = parseFloat(match[4]);
          models[modelId] = {
            input: price,
            output: price,
          };
        }
      }
    }

    // Add fallback for common models if not found in scrape
    const fallbackModels: Record<string, ModelPricing> = {
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

    // Merge fallbacks for any missing models
    for (const [modelId, pricing] of Object.entries(fallbackModels)) {
      if (!models[modelId]) {
        models[modelId] = pricing;
      }
    }

    return {
      models,
      fetchedAt: Date.now(),
    };
  } catch (error) {
    console.error("Failed to fetch pricing data:", error);

    // Return fallback pricing on error
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
        "accounts/fireworks/models/mixtral-8x22b-instruct": { input: 0.9, output: 0.9 },
      },
      fetchedAt: Date.now(),
    };
  }
}

// ── Extension Entry Point ───────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    // Reset counters
    state.counts = {};
    state.pricingLoading = false;

    // Load from disk cache immediately (instant startup)
    const cached = loadPricingCache();
    if (cached) {
      state.pricing = cached;
    }

    // Set up the footer (before async fetch so tuiRef is available)
    let tuiRef: { requestRender: () => void } | null = null;

    ctx.ui.setFooter((tui, theme, footerData) => {
      tuiRef = tui;
      const unsub = footerData.onBranchChange(() => tui.requestRender());

      return {
        dispose: unsub,
        invalidate() {},
        render(width: number): string[] {
          // Calculate tokens and cost on every render (more reliable)
          let tokIn = 0;
          let tokOut = 0;
          let cost = 0;

          for (const entry of ctx.sessionManager.getBranch()) {
            if (entry.type === "message" && entry.message.role === "assistant") {
              const m = entry.message as AssistantMessage;
              tokIn += m.usage.input;
              tokOut += m.usage.output;

              if (state.pricing?.models[m.model]) {
                const pricing = state.pricing.models[m.model];
                cost += (m.usage.input * pricing.input) / 1_000_000 + (m.usage.output * pricing.output) / 1_000_000;
              }
            }
          }

          // Format numbers
          const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
          const fmtCost = (n: number) => (n < 0.01 ? `$${n.toFixed(4)}` : `$${n.toFixed(3)}`);
          const costDisplay = state.pricingLoading ? "$?" : fmtCost(cost);

          const dir = basename(ctx.cwd);
          const branch = footerData.getGitBranch();
          const usage = ctx.getContextUsage();
          const pct = usage ? usage.percent : 0;
          const filled = Math.round(pct / 10) || 1;
          const model = ctx.model?.id || "no-model";

          // --- Line 1: Model + context meter (left), tokens + cost (right) ---
          const l1Left =
            theme.fg("dim", ` ${model} `) +
            theme.fg("warning", "[") +
            theme.fg("success", "#".repeat(filled)) +
            theme.fg("dim", "-".repeat(10 - filled)) +
            theme.fg("warning", "]") +
            theme.fg("dim", " ") +
            theme.fg("accent", `${Math.round(pct)}%`);

          const l1Right =
            theme.fg("success", `${fmt(tokIn)}`) +
            theme.fg("dim", " in ") +
            theme.fg("accent", `${fmt(tokOut)}`) +
            theme.fg("dim", " out ") +
            theme.fg("warning", costDisplay) +
            theme.fg("dim", " ");

          const pad1 = " ".repeat(Math.max(1, width - visibleWidth(l1Left) - visibleWidth(l1Right)));
          const line1 = truncateToWidth(l1Left + pad1 + l1Right, width, "");

          // --- Line 2: Cwd + branch (left), tool tally (right) ---
          const l2Left =
            theme.fg("dim", ` ${dir}`) +
            (branch
              ? theme.fg("dim", " ") +
                theme.fg("warning", "(") +
                theme.fg("success", branch) +
                theme.fg("warning", ")")
              : "");

          const entries = Object.entries(state.counts);
          const l2Right =
            entries.length === 0
              ? theme.fg("dim", "waiting for tools ")
              : entries
                  .map(
                    ([name, count]) =>
                      theme.fg("accent", name) + theme.fg("dim", " ") + theme.fg("success", `${count}`),
                  )
                  .join(theme.fg("warning", " | ")) + theme.fg("dim", " ");

          const pad2 = " ".repeat(Math.max(1, width - visibleWidth(l2Left) - visibleWidth(l2Right)));
          const line2 = truncateToWidth(l2Left + pad2 + l2Right, width, "");

          return [line1, line2];
        },
      };
    });

    // Fetch async if no valid cache (non-blocking)
    const shouldFetch = !state.pricing || Date.now() - state.pricing.fetchedAt > CACHE_TTL;
    if (shouldFetch) {
      state.pricingLoading = true;
      fetchModelPricing().then((data) => {
        state.pricing = data;
        state.pricingLoading = false;
        savePricingCache(data);
        // Request re-render to show updated pricing
        tuiRef?.requestRender();
      });
    }
  });

  // Track tool execution counts
  pi.on("tool_execution_end", async (event) => {
    state.counts[event.toolName] = (state.counts[event.toolName] || 0) + 1;
  });
}
