/**
 * Session Friction Review — Focus on what went wrong and how to fix it
 *
 * Analyzes current session for:
 * - Debug hell (repeated attempts at same thing)
 * - Silent failures (crashes with no output)
 * - Documentation gaps (missing info that would help)
 * - Tool friction (clunky workflows)
 *
 * Commands:
 *   /review              — Analyze current session friction
 *   /review --save     — Save review to .context/reviews/
 *   /review-all          — Review all sessions for patterns
 *
 * Usage: pi -e ~/.pi/agent/extensions/harness-review.ts
 */

import type { ExtensionAPI, ExtensionContext, SessionEntry, Message } from "@mariozechner/pi-coding-agent";
import { Type } from "@sinclair/typebox";
import { Text } from "@mariozechner/pi-tui";
import { existsSync, mkdirSync, writeFileSync, readdirSync, readFileSync, statSync } from "fs";
import { join, basename } from "path";
import { homedir } from "os";

// ── Types ──────────────────────────────────────────────────────────────

interface FrictionPoint {
  category: "debug_hell" | "silent_failure" | "repeated_fix" | "doc_gap" | "tool_friction" | "pattern";
  description: string;
  evidence: string[];
  rootCause?: string;
  fix?: string;
  prevention?: string;
  priority: "high" | "medium" | "low";
}

interface Suggestion {
  type: "agents_update" | "new_skill" | "workflow_fix" | "config_change";
  description: string;
  details?: string;
  file?: string;
  priority: "high" | "medium" | "low";
}

interface ReviewResult {
  frictionPoints: FrictionPoint[];
  suggestions: Suggestion[];
  summary: string;
  debugInfo: {
    branchLength: number;
    messageCount: number;
  };
}

// ── Friction Detection Patterns ─────────────────────────────────────────

const PATTERNS = [
  {
    name: "ssh_debug_hell",
    regex: /(?:ssh.*(?:fail|error|timeout|verification|host key)|ssh-keyscan|strict.*host.*key|accept-new)/i,
    category: "debug_hell" as const,
    priority: "high" as const,
    description: "SSH connection required multiple attempts",
    prevention: "Add SSH troubleshooting playbook to AGENTS.md",
  },
  {
    name: "silent_container_crash",
    regex: /(?:container.*(?:exit|crash|code 1)|empty.*log|no.*output|silen.*fail)/i,
    category: "silent_failure" as const,
    priority: "high" as const,
    description: "Container/service crashed without clear error output",
    prevention: "Add debug container command to AGENTS.md workflow",
  },
  {
    name: "wrong_secret_format",
    regex: /(?:master.*key|secret.*wrong|invalid.*key|must be 16 bytes|docker.*pat|rails_master_key)/i,
    category: "repeated_fix" as const,
    priority: "high" as const,
    description: "Secret/key had wrong format or value",
    prevention: "Add secrets validation checklist to AGENTS.md",
  },
  {
    name: "repeated_toggles",
    regex: /(?:task.*toggle|toggle.*\d+ times|one by one|manually.*toggle)/i,
    category: "tool_friction" as const,
    priority: "medium" as const,
    description: "Repetitive task toggle operations",
    prevention: "Create batch task operations skill",
  },
  {
    name: "missing_docs",
    regex: /(?:not documented|should have|would have helped|where is|how do|what.*\?|missing.*playbook)/i,
    category: "doc_gap" as const,
    priority: "medium" as const,
    description: "Missing documentation that would have prevented friction",
    prevention: "Document the gap in AGENTS.md",
  },
  {
    name: "health_check_fails",
    regex: /(?:health.*check|unhealthy|timeout.*30s|target failed|kamal.*deploy)/i,
    category: "debug_hell" as const,
    priority: "high" as const,
    description: "Deploy health checks failing repeatedly",
    prevention: "Add health check debugging section to AGENTS.md",
  },
  {
    name: "registry_auth_issues",
    regex: /(?:ghcr|docker.*hub|registry|unauthorized|permission|denied|login)/i,
    category: "debug_hell" as const,
    priority: "medium" as const,
    description: "Container registry authentication problems",
    prevention: "Document registry setup in AGENTS.md",
  },
  {
    name: "duplicate_creation",
    regex: /(?:already.*exist|duplicate|didn't check|should have checked|exists)/i,
    category: "pattern" as const,
    priority: "low" as const,
    description: "Created something that already existed",
    prevention: "Add 'check before create' pattern to workflow",
  },
];

// ── Analysis Functions ──────────────────────────────────────────────────

function analyzeCurrentSession(ctx: ExtensionContext): ReviewResult {
  const branch = ctx.sessionManager.getBranch();
  const points: FrictionPoint[] = [];
  
  // Debug: Check what we're analyzing
  const debugInfo = {
    branchLength: branch.length,
    messageCount: branch.filter(e => e.type === "message").length,
    firstFewTypes: branch.slice(0, 5).map(e => e.type),
  };
  
  // Group messages for context
  const messages = branch
    .filter((e): e is SessionEntry & { type: "message" } => e.type === "message")
    .map(e => e.message);
  
  // Debug: Log message count
  console.log(`[review] Analyzing ${messages.length} messages, branch has ${branch.length} entries`);
  
  // Check for friction patterns
  for (const pattern of PATTERNS) {
    const matches: string[] = [];
    
    for (let i = 0; i < messages.length; i++) {
      const msg = messages[i];
      const context = extractContext(msg);
      const text = context.toLowerCase();
      
      if (pattern.regex.test(text)) {
        if (context && !matches.includes(context)) {
          matches.push(context);
        }
      }
    }
    
    if (matches.length > 0) {
      points.push({
        category: pattern.category,
        description: pattern.description,
        evidence: matches.slice(0, 3),
        prevention: pattern.prevention,
        priority: pattern.priority,
      });
    }
  }

  // Detect debug hell: repeated bash/edit on same thing
  const debugHellPoints = detectDebugHell(messages);
  points.push(...debugHellPoints);
  
  // Generate suggestions from friction points
  const suggestions = generateSuggestions(points);
  
  // Create summary
  const highCount = points.filter(p => p.priority === "high").length;
  const summary = highCount > 0 
    ? `Found ${points.length} friction points (${highCount} high priority). Focus on prevention docs.`
    : points.length > 0
    ? `Found ${points.length} friction points. Consider documentation updates.`
    : "No major friction detected. Session went smoothly!";

  return { 
    frictionPoints: points, 
    suggestions, 
    summary,
    debugInfo: {
      branchLength: branch.length,
      messageCount: messages.length,
    }
  };
}

function extractContext(msg: Message): string {
  // Handle different message formats
  const parts: string[] = [];
  
  // User text
  if (msg.role === "user" && typeof msg.content === "string") {
    parts.push(msg.content);
  }
  if (msg.role === "user" && Array.isArray(msg.content)) {
    for (const c of msg.content) {
      if (c.type === "text") parts.push(c.text);
    }
  }
  
  // Assistant content
  if (msg.role === "assistant") {
    if (Array.isArray(msg.content)) {
      for (const c of msg.content) {
        if (c.type === "text") parts.push(c.text);
        if (c.type === "thinking") parts.push(c.thinking);
      }
    }
    // Tool calls
    if (msg.toolCalls) {
      for (const tc of msg.toolCalls) {
        parts.push(`${tc.name}: ${JSON.stringify(tc.arguments)}`);
      }
    }
  }
  
  // Tool results
  if (msg.isError && msg.content) {
    parts.push(`ERROR: ${JSON.stringify(msg.content)}`);
  }
  
  return parts.join(" ").slice(0, 150).replace(/\n/g, " ");
}

function detectDebugHell(messages: Message[]): FrictionPoint[] {
  const points: FrictionPoint[] = [];
  
  // Look for repeated edit/bash attempts on same file/command
  const fileAttempts = new Map<string, number>();
  const commandAttempts = new Map<string, number>();
  
  for (const msg of messages) {
    if (msg.role !== "assistant" || !msg.toolCalls?.length) continue;
    
    for (const tc of msg.toolCalls) {
      // Track file edits
      if (tc.name === "edit" || tc.name === "read") {
        const path = JSON.stringify(tc.arguments).match(/"path":"([^"]+)"/)?.[1];
        if (path) {
          fileAttempts.set(path, (fileAttempts.get(path) || 0) + 1);
        }
      }
      
      // Track bash commands
      if (tc.name === "bash") {
        const cmd = JSON.stringify(tc.arguments).match(/"command":"([^"]+)"/)?.[1];
        if (cmd && (cmd.includes("deploy") || cmd.includes("ssh") || cmd.includes("fix"))) {
          commandAttempts.set(cmd.slice(0, 50), (commandAttempts.get(cmd.slice(0, 50)) || 0) + 1);
        }
      }
    }
  }
  
  // Find files edited >3 times (debug hell indicator)
  for (const [file, count] of fileAttempts) {
    if (count > 3 && !file.includes("AGENTS.md")) {
      points.push({
        category: "debug_hell",
        description: `File required ${count} edit attempts`,
        evidence: [file],
        rootCause: "Unclear requirements or trial-and-error approach",
        prevention: `Add "${basename(file)} patterns" to AGENTS.md with correct approach`,
        priority: "medium",
      });
    }
  }
  
  // Find repeated commands
  for (const [cmd, count] of commandAttempts) {
    if (count > 5) {
      points.push({
        category: "debug_hell",
        description: `Command attempted ${count} times`,
        evidence: [cmd],
        rootCause: "Working around a persistent issue",
        prevention: "Document the root cause and solution in AGENTS.md",
        priority: "high",
      });
    }
  }
  
  return points;
}

function generateSuggestions(points: FrictionPoint[]): Suggestion[] {
  const suggestions: Suggestion[] = [];
  
  for (const point of points) {
    switch (point.category) {
      case "debug_hell":
        if (point.evidence.some(e => e.includes("SSH") || e.includes("ssh"))) {
          suggestions.push({
            type: "agents_update",
            description: "SSH Troubleshooting Decision Tree",
            details: "Add flowchart: SSH fails → check Tailscale → check host keys → check StrictHostKeyChecking",
            file: "AGENTS.md",
            priority: "high",
          });
        }
        if (point.evidence.some(e => e.includes("deploy") || e.includes("container"))) {
          suggestions.push({
            type: "agents_update",
            description: "Deploy Debug Playbook",
            details: "Document: Container exits immediately → SSH to server → run container manually → capture actual error",
            file: "AGENTS.md",
            priority: "high",
          });
        }
        break;
        
      case "silent_failure":
        suggestions.push({
          type: "workflow_fix",
          description: "Add automatic container log capture on deploy failure",
          details: "Update GitHub Actions workflow to capture 'docker logs' when deploy fails",
          priority: "high",
        });
        break;
        
      case "repeated_fix":
        if (point.description.includes("secret") || point.description.includes("key")) {
          suggestions.push({
            type: "agents_update",
            description: "Secrets Validation Checklist",
            details: "Add: RAILS_MASTER_KEY must be 32 hex chars (not Docker PAT!), check with `wc -c`",
            file: "AGENTS.md",
            priority: "high",
          });
        }
        break;
        
      case "tool_friction":
        if (point.description.includes("toggle")) {
          suggestions.push({
            type: "new_skill",
            description: "Batch task operations",
            details: "Add tilldone batch commands: `tilldone done-all`, `tilldone toggle-range 1-5`",
            priority: "medium",
          });
        }
        break;
        
      case "doc_gap":
        suggestions.push({
          type: "agents_update",
          description: `Document: ${point.prevention}`,
          file: "AGENTS.md",
          priority: point.priority,
        });
        break;
    }
  }
  
  // Remove duplicates
  const seen = new Set<string>();
  return suggestions.filter(s => {
    const key = `${s.type}:${s.description}`;
    if (seen.has(key)) return false;
    seen.add(key);
    return true;
  });
}

// ── Report Formatting ───────────────────────────────────────────────────

function formatReport(result: ReviewResult, savePath?: string): string {
  const lines: string[] = [];
  
  lines.push("# Session Friction Review");
  lines.push("");
  lines.push(`**${result.summary}**`);
  lines.push("");
  lines.push(`*(Analyzed ${result.debugInfo.messageCount} messages from ${result.debugInfo.branchLength} branch entries)*`);
  if (savePath) {
    lines.push(`*Saved to: \`${savePath}\`*`);
  }
  lines.push("");
  
  if (result.frictionPoints.length === 0) {
    lines.push("✅ No significant friction detected.");
    lines.push("");
    lines.push("This session went smoothly without repeated attempts or silent failures.");
    return lines.join("\n");
  }
  
  // Group by priority
  const high = result.frictionPoints.filter(p => p.priority === "high");
  const medium = result.frictionPoints.filter(p => p.priority === "medium");
  const low = result.frictionPoints.filter(p => p.priority === "low");
  
  if (high.length > 0) {
    lines.push("## 🔴 High Priority Friction");
    lines.push("");
    for (const point of high) {
      formatFrictionPoint(lines, point);
    }
  }
  
  if (medium.length > 0) {
    lines.push("## 🟡 Medium Priority Friction");
    lines.push("");
    for (const point of medium) {
      formatFrictionPoint(lines, point);
    }
  }
  
  if (low.length > 0) {
    lines.push("## 🟢 Low Priority Friction");
    lines.push("");
    for (const point of low) {
      formatFrictionPoint(lines, point);
    }
  }
  
  // Suggestions
  if (result.suggestions.length > 0) {
    lines.push("---");
    lines.push("");
    lines.push("## 💡 Suggested Improvements");
    lines.push("");
    
    const agentsUpdates = result.suggestions.filter(s => s.type === "agents_update");
    const newSkills = result.suggestions.filter(s => s.type === "new_skill");
    const workflowFixes = result.suggestions.filter(s => s.type === "workflow_fix");
    
    if (agentsUpdates.length > 0) {
      lines.push("### AGENTS.md Updates");
      lines.push("");
      for (const s of agentsUpdates) {
        lines.push(`- [ ] **${s.description}**`);
        if (s.details) {
          lines.push(`  - ${s.details}`);
        }
        lines.push("");
      }
    }
    
    if (newSkills.length > 0) {
      lines.push("### New Skills to Create");
      lines.push("");
      for (const s of newSkills) {
        lines.push(`- [ ] **${s.description}**`);
        if (s.details) {
          lines.push(`  - ${s.details}`);
        }
        lines.push("");
      }
    }
    
    if (workflowFixes.length > 0) {
      lines.push("### Workflow/Config Fixes");
      lines.push("");
      for (const s of workflowFixes) {
        lines.push(`- [ ] **${s.description}**`);
        if (s.details) {
          lines.push(`  - ${s.details}`);
        }
        lines.push("");
      }
    }
  }
  
  lines.push("---");
  lines.push("");
  lines.push("**Next Steps:**");
  lines.push("1. Review friction points above");
  lines.push("2. Consider which suggestions to implement");
  lines.push("3. Say 'yes' to any suggestion and I'll help create it");
  lines.push("4. Or say 'add to AGENTS.md' to document specific friction");
  
  return lines.join("\n");
}

function formatFrictionPoint(lines: string[], point: FrictionPoint) {
  lines.push(`### ${point.description}`);
  lines.push("");
  
  if (point.evidence.length > 0) {
    lines.push("**Evidence:**");
    for (const ev of point.evidence) {
      lines.push(`- ${ev}`);
    }
    lines.push("");
  }
  
  if (point.rootCause) {
    lines.push(`**Root Cause:** ${point.rootCause}`);
    lines.push("");
  }
  
  if (point.prevention) {
    lines.push(`**Prevention:** ${point.prevention}`);
    lines.push("");
  }
}

// ── File Operations ─────────────────────────────────────────────────────

function saveReview(report: string): string {
  const reviewsDir = join(process.cwd(), ".context", "reviews");
  if (!existsSync(reviewsDir)) {
    mkdirSync(reviewsDir, { recursive: true });
  }
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-").slice(0, 19);
  const filename = `friction-review-${timestamp}.md`;
  const filepath = join(reviewsDir, filename);
  
  writeFileSync(filepath, report, "utf-8");
  return filepath;
}

// ── Extension Entry Point ───────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // Tool: review_session (current session friction analysis)
  pi.registerTool({
    name: "review_session",
    label: "review session",
    description: "Analyze current session for friction points and improvement opportunities",
    parameters: Type.Object({
      save: Type.Optional(Type.Boolean({ 
        description: "Save review to .context/reviews/",
        default: false 
      })),
    }),
    
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      onUpdate?.({
        content: [{ type: "text", text: "🔍 Analyzing session for friction points..." }],
      });
      
      const result = analyzeCurrentSession(ctx);
      
      onUpdate?.({
        content: [{ type: "text", text: `Found ${result.frictionPoints.length} friction points (${result.debugInfo.messageCount} messages analyzed)` }],
      });
      
      // Generate and optionally save report
      let savePath: string | undefined;
      const report = formatReport(result, savePath);
      
      if (params.save) {
        savePath = saveReview(report);
      }
      
      return {
        content: [{ type: "text", text: report }],
        details: { 
          frictionCount: result.frictionPoints.length,
          suggestionCount: result.suggestions.length,
          savedPath: savePath,
          suggestions: result.suggestions,
        },
      };
    },
    
    renderCall(args, theme) {
      return new Text(
        theme.fg("toolTitle", theme.bold("review_session ")) +
        theme.fg("dim", args.save ? "(save)" : ""),
        0, 0
      );
    },
    
    renderResult(result, options, theme) {
      if (options.isPartial) {
        return new Text(theme.fg("accent", "Analyzing friction..."), 0, 0);
      }
      
      const count = result.details?.frictionCount ?? 0;
      const saved = result.details?.savedPath;
      
      if (count === 0) {
        return new Text(
          theme.fg("success", `✅ No friction detected${saved ? " (saved)" : ""}`),
          0, 0
        );
      }
      
      return new Text(
        theme.fg("warning", 
          `⚠ Found ${count} friction points${saved ? " (saved)" : ""}`
        ),
        0, 0
      );
    },
  });

  // Tool: harness_review (all sessions - kept for compatibility)
  pi.registerTool({
    name: "harness_review",
    label: "harness review",
    description: "Analyze all session history across projects",
    parameters: Type.Object({
      full: Type.Optional(Type.Boolean({ default: false })),
    }),
    
    async execute(toolCallId, params, signal, onUpdate, ctx) {
      onUpdate?.({
        content: [{ type: "text", text: "📊 Analyzing all session history..." }],
      });
      
      // Simple aggregate stats for now
      const sessionsDir = join(homedir(), ".pi", "agent", "sessions");
      let sessionCount = 0;
      let projectCount = 0;
      
      try {
        const dirs = readdirSync(sessionsDir, { withFileTypes: true })
          .filter(d => d.isDirectory());
        projectCount = dirs.length;
        
        for (const dir of dirs) {
          const files = readdirSync(join(sessionsDir, dir.name))
            .filter(f => f.endsWith(".jsonl"));
          sessionCount += files.length;
        }
      } catch {
        // Ignore errors
      }
      
      const report = [
        "# All Sessions Overview",
        "",
        `**${sessionCount}** sessions across **${projectCount}** projects`,
        "",
        "💡 **Tip:** Use `/review` to analyze the current session for friction points.",
        "",
        "The detailed cross-session analysis has been simplified.",
        "Focus on current session friction with `/review` instead.",
      ].join("\n");
      
      return {
        content: [{ type: "text", text: report }],
        details: { sessionCount, projectCount },
      };
    },
  });

  // Command: /review
  pi.registerCommand("review", {
    description: "Analyze current session for friction and improvement opportunities",
    handler: async (args, ctx) => {
      const saveFlag = args.includes("--save");
      pi.sendUserMessage(`/review_session ${saveFlag ? "save=true" : ""}`, { deliverAs: "steer" });
    },
  });

  // Command: /review-all-sessions (kept for compatibility, redirects)
  pi.registerCommand("review-all-sessions", {
    description: "Show overview of all sessions (use /review for current session analysis)",
    handler: async (_args, ctx) => {
      pi.sendUserMessage("/harness_review", { deliverAs: "steer" });
    },
  });
}
