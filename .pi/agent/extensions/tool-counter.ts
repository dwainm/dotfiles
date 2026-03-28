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

function getShortModelName(modelId: string): string {
  // Extract the model name from the full ID
  const parts = modelId.split('/');
  const name = parts[parts.length - 1] || modelId;
  
  // Common model name mappings
  const mappings: Record<string, string> = {
    'kimi-k2p5-turbo': 'K2.5-Turbo',
    'kimi-k2p5': 'K2.5',
    'kimi-k2-thinking': 'K2-Thinking',
    'kimi-k2': 'K2',
    'deepseek-v3p2': 'DS-V3.2',
    'deepseek-v3p1': 'DS-V3.1',
    'deepseek-r1': 'DS-R1',
    'minimax-m2p5': 'MiniMax',
    'glm-5': 'GLM-5',
    'glm-4p7': 'GLM-4.7',
    'cogito-671b-v2-p1': 'Cogito-671B',
    'gpt-oss-120b': 'GPT-OSS-120B',
    'gpt-oss-20b': 'GPT-OSS-20B',
    'qwen3-8b': 'Qwen3-8B',
    'mixtral-8x22b-instruct': 'Mixtral',
  };
  
  // Try to match the mapping
  for (const [key, value] of Object.entries(mappings)) {
    if (name.toLowerCase().includes(key.toLowerCase())) {
      return value;
    }
  }
  
  // Fallback: truncate long names
  return name.length > 12 ? name.slice(0, 10) + '..' : name;
}

function getModelPricing(modelId: string, pricing: PricingData | null): { input: number; output: number } | null {
  if (!pricing?.models[modelId]) {
    // Try to infer from model name patterns
    if (modelId.includes('kimi-k2p5')) return { input: 0.6, output: 2.5 };
    if (modelId.includes('kimi-k2')) return { input: 0.6, output: 2.5 };
    if (modelId.includes('deepseek-v3')) return { input: 0.56, output: 2.5 };
    if (modelId.includes('deepseek-r1')) return { input: 0.75, output: 2.5 };
    if (modelId.includes('minimax')) return { input: 0.3, output: 1.0 };
    if (modelId.includes('glm-5')) return { input: 1.0, output: 3.2 };
    if (modelId.includes('glm-4')) return { input: 0.6, output: 1.8 };
    if (modelId.includes('cogito')) return { input: 1.2, output: 3.0 };
    if (modelId.includes('gpt-oss-120b')) return { input: 0.15, output: 0.5 };
    if (modelId.includes('gpt-oss-20b')) return { input: 0.07, output: 0.25 };
    if (modelId.includes('qwen3')) return { input: 0.2, output: 0.6 };
    if (modelId.includes('mixtral')) return { input: 0.9, output: 0.9 };
    return null;
  }
  return pricing.models[modelId];
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

    // Get current model info
    const currentModel = ctx.model;
    const modelId = currentModel?.id || "unknown";
    const shortName = getShortModelName(modelId);
    const pricing = getModelPricing(modelId, state.pricing);
    
    const totalCost = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.cost, 0);
    const totalInput = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.input, 0);
    const totalOutput = Object.values(state.messageCosts).reduce((sum, msg) => sum + msg.output, 0);
    const totalCacheRead = Object.values(state.messageCosts).reduce((sum, msg) => sum + (msg.cacheRead || 0), 0);
    const totalCacheWrite = Object.values(state.messageCosts).reduce((sum, msg) => sum + (msg.cacheWrite || 0), 0);
    const totalTokens = totalInput + totalOutput + totalCacheRead + totalCacheWrite;

    const fmt = (n: number) => (n < 1000 ? `${n}` : `${(n / 1000).toFixed(1)}k`);
    const fmtCost = (n: number) => (n < 0.01 ? `$${n.toFixed(4)}` : `$${n.toFixed(3)}`);
    
    // Build model badge with pricing
    let modelBadge = shortName;
    if (pricing) {
      modelBadge = `${shortName}($${pricing.input.toFixed(2)}/$${pricing.output.toFixed(1)}/M)`;
    }
    
    const costDisplay = state.pricingLoading ? "$?" : fmtCost(totalCost);
    const tokensDisplay = `${fmt(totalTokens)}(${fmt(totalInput)}/${fmt(totalOutput)}|${fmt(totalCacheRead)})`;
    
    let creditDisplay = "";
    if (state.startingCredit !== null) {
      const remaining = Math.max(0, state.startingCredit - totalCost);
      creditDisplay = ` [$${state.startingCredit.toFixed(2)}->$${remaining.toFixed(2)}]`;
    }

    const display = `${modelBadge} ${costDisplay} ${tokensDisplay}${creditDisplay}`;
    return { lines: [display], priority: 100 };
  });
}
