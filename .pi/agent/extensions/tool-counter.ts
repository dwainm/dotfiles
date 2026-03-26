import { type ExtensionAPI } from "@mariozechner/pi-coding-agent";
import { registerPanel, requestRender } from "./lib/footer-registry";
import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";

interface MessageCost {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  model: string;
  cost: number;
}

interface PricingData {
  fetchedAt: number;
  models: Record<string, { input: number; output: number }>;
}

const state = {
  messageCosts: {} as Record<string, MessageCost>,
  pricing: null as PricingData | null,
  pricingLoading: false,
  startingCredit: null as number | null,
};

function getPricingCachePath(): string {
  return join(process.env.HOME || "", ".pi", "agent", ".pricing-cache.json");
}

function loadPricingCache(): PricingData | null {
  try {
    const path = getPricingCachePath();
    if (!existsSync(path)) return null;
    const data = JSON.parse(readFileSync(path, "utf-8"));
    if (Date.now() - data.fetchedAt < 24 * 60 * 60 * 1000) return data;
    return null;
  } catch {
    return null;
  }
}

async function fetchModelPricing(): Promise<PricingData> {
  try {
    const response = await fetch("https://fireworks.ai/models");
    const html = await response.text();
    
    const pricing: PricingData = {
      fetchedAt: Date.now(),
      models: {}
    };

    const lines = html.split('\n');
    for (const line of lines) {
      if (line.includes('glm-5') && line.includes('$')) {
        pricing.models["accounts/fireworks/models/glm-5"] = { input: 1.0, output: 3.2 };
      }
      if (line.includes('kimi-k2-thinking') && line.includes('$')) {
        pricing.models["accounts/fireworks/models/kimi-k2-thinking"] = { input: 0.6, output: 2.5 };
      }
    }
    
    if (!pricing.models["accounts/fireworks/models/glm-5"]) {
      pricing.models["accounts/fireworks/models/glm-5"] = { input: 1.0, output: 3.2 };
    }
    if (!pricing.models["accounts/fireworks/models/kimi-k2-thinking"]) {
      pricing.models["accounts/fireworks/models/kimi-k2-thinking"] = { input: 0.6, output: 2.5 };
    }

    return pricing;
  } catch (error) {
    console.error("Failed to fetch pricing:", error);
    return {
      fetchedAt: Date.now(),
      models: {
        "accounts/fireworks/models/glm-5": { input: 1.0, output: 3.2 },
        "accounts/fireworks/models/kimi-k2-thinking": { input: 0.6, output: 2.5 }
      }
    };
  }
}

async function fetchAccountCredit(): Promise<number | null> {
  try {
    const { exec } = await import("node:child_process");
    const util = await import("node:util");
    const execAsync = util.promisify(exec);
    
    const firectlPath = "/opt/homebrew/bin/firectl";
    const { stdout } = await execAsync(`${firectlPath} account get`);
    
    const match = stdout.match(/Balance:\s*USD\s*([0-9]+\.?[0-9]*)/);
    if (match && match[1]) {
      return parseFloat(match[1]);
    }
    
    return null;
  } catch (error) {
    console.error("Failed to fetch account credit:", error);
    return null;
  }
}

export default function (pi: ExtensionAPI) {
  pi.on("session_start", async (_event, ctx) => {
    requestRender();
    
    state.pricingLoading = true;
    requestRender();
    
    const cached = loadPricingCache();
    if (cached) {
      state.pricing = cached;
      state.pricingLoading = false;
      requestRender();
    } else {
      fetchModelPricing().then(pricing => {
        state.pricing = pricing;
        state.pricingLoading = false;
        requestRender();
      });
    }
    
    fetchAccountCredit().then(credit => {
      state.startingCredit = credit;
      requestRender();
    });
  });

  pi.on("turn_end", async (event, ctx) => {
    const m = event.message;
    if (!m || m.role !== "assistant" || !m.usage) {
      return;
    }
    
    const messageId = m.id || `${Date.now()}-${Math.random().toString(36).slice(2, 11)}`;
    
    let cost = 0;
    if (state.pricing?.models[m.model]) {
      const p = state.pricing.models[m.model];
      cost = (m.usage.input * p.input + m.usage.output * p.output + (m.usage.cacheRead || 0) * p.input * 0.5) / 1_000_000;
    }
    
    state.messageCosts[messageId] = {
      input: m.usage.input,
      output: m.usage.output,
      cacheRead: m.usage.cacheRead || 0,
      cacheWrite: m.usage.cacheWrite || 0,
      model: m.model,
      cost: cost
    };
    
    requestRender();
  });

  registerPanel("tool-counter", (width, theme, ctx) => {
    if (!state.pricing && !state.pricingLoading) {
      return { lines: ["$? 0/0"], priority: 100 };
    }

    const totalCost = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.cost, 0);
    const totalInput = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.input, 0);
    const totalOutput = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.output, 0);
    const totalCacheRead = Object.values(state.messageCosts).reduce((sum, msg) => sum + (msg.cacheRead || 0), 0);
    const totalCacheWrite = Object.values(state.messageCosts).reduce((sum, msg) => sum + (msg.cacheWrite || 0), 0);
    const totalTokens = totalInput + totalOutput + totalCacheRead + totalCacheWrite;

    const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
    const fmtCost = (n: number) => (n < 0.01 ? `$${n.toFixed(4)}` : `$${n.toFixed(3)}`);
    
    const costDisplay = state.pricingLoading ? " $?" : ` ${fmtCost(totalCost)}`;
    const tokensDisplay = `${fmt(totalTokens)}(${fmt(totalInput)}/${fmt(totalOutput)}|${fmt(totalCacheRead)})`;
    
    let creditDisplay = "";
    if (state.startingCredit !== null) {
      const remaining = Math.max(0, state.startingCredit - totalCost);
      creditDisplay = ` [$${state.startingCredit.toFixed(2)} -> $${remaining.toFixed(2)}]`;
    }

    const display = `${costDisplay} ${tokensDisplay}${creditDisplay}`;
    return { lines: [display], priority: 100 };
  });
}
