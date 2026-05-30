import { List, ActionPanel, Action, Icon, showToast, Toast, getPreferenceValues } from "@raycast/api";
import { execSync } from "child_process";
import { readFileSync } from "fs";
import { useState, useEffect } from "react";

interface Binding {
  mode: string;
  key: string;
  description: string;
  isModeSwitch: boolean;
}

const MODE_EMOJIS: Record<string, string> = {
  default: "⌨️",
  service: "🔧",
  workspace: "🖥️",
  launcher: "🚀",
  writing: "✍️",
  break: "☕",
};

const MODE_NAMES: Record<string, string> = {
  default: "Default",
  service: "Service",
  workspace: "Workspace",
  launcher: "Launcher",
  writing: "Writing",
  break: "Break",
};

function resolveHexKey(key: string): string {
  const hexMap: Record<string, string> = {
    "0x1B": "-",
    "0x18": "=",
    "0x1E": "]",
    "0x21": "[",
    "0x2A": "\\",
  };
  return hexMap[key] || key;
}

function parseSkhdrc(path: string): Binding[] {
  const content = readFileSync(path, "utf-8");
  const lines = content.split("\n");
  const bindings: Binding[] = [];
  let currentMode = "default";
  let pendingComment = "";

  for (const line of lines) {
    const trimmed = line.trim();

    // Empty line resets pending comment
    if (!trimmed) {
      pendingComment = "";
      continue;
    }

    // Track mode declarations
    const modeDeclMatch = trimmed.match(/^::\s+([a-z]+)/);
    if (modeDeclMatch) {
      currentMode = modeDeclMatch[1];
      pendingComment = "";
      continue;
    }

    // Capture comment lines (but not section headers)
    if (trimmed.startsWith("#")) {
      const commentContent = trimmed.replace(/^#\s*/, "");
      if (commentContent && !commentContent.match(/^[-=]+/)) {
        pendingComment = commentContent;
      }
      continue;
    }

    // Skip if no pending comment
    if (!pendingComment) continue;

    const description = pendingComment;
    pendingComment = "";

    // Skip lines inside multi-line blocks
    if (trimmed.startsWith("*") || trimmed.startsWith('"') || trimmed.startsWith("]")) continue;

    // Mode-specific bindings: mode < key
    const modeMatch = trimmed.match(/^([a-z]+)\s*<\s*(.+?)(?:\s*[:;]\s*)/);
    if (modeMatch) {
      const mode = modeMatch[1];
      let key = modeMatch[2].trim();
      key = resolveHexKey(key);
      // Clean up key - remove everything after : or ;
      key = key.replace(/\s*[:;].*$/, "").trim();
      const isModeSwitch = description.includes("return to") || description.includes("enter") || description.includes("switch to");
      bindings.push({ mode, key, description, isModeSwitch });
      continue;
    }

    // Global bindings
    const keyPart = trimmed.replace(/\s*[:;].*$/, "").replace(/\s*\[.*$/, "").trim();
    if (!keyPart) continue;

    const words = keyPart.split(/\s+/);
    const rawKey = words[words.length - 1];
    const key = resolveHexKey(rawKey);
    const modifiers = words.slice(0, -1).join(" ");

    const displayKey = modifiers ? `${modifiers} ${key}` : key;
    const isModeSwitch = description.includes("return to") || description.includes("enter") || description.includes("switch to");
    bindings.push({ mode: currentMode, key: displayKey, description, isModeSwitch });
  }

  return bindings;
}

function executeBinding(binding: Binding) {
  try {
    execSync(`skhd -k "${binding.key}"`, { timeout: 5000 });
    showToast({
      style: Toast.Style.Success,
      title: "Executed",
      message: binding.description,
    });
  } catch (error) {
    showToast({
      style: Toast.Style.Failure,
      title: "Failed to execute",
      message: String(error),
    });
  }
}

export default function Command() {
  const [bindings, setBindings] = useState<Binding[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    try {
      const parsed = parseSkhdrc("/Users/dwain/.config/skhd/skhdrc");
      setBindings(parsed);
    } catch (error) {
      showToast({
        style: Toast.Style.Failure,
        title: "Failed to parse skhdrc",
        message: String(error),
      });
    } finally {
      setIsLoading(false);
    }
  }, []);

  const grouped = bindings.reduce((acc, binding) => {
    if (!acc[binding.mode]) acc[binding.mode] = [];
    acc[binding.mode].push(binding);
    return acc;
  }, {} as Record<string, Binding[]>);

  const modeOrder = ["default", "workspace", "launcher", "writing", "break", "service"];

  return (
    <List isLoading={isLoading} searchBarPlaceholder="Search keybindings...">
      {modeOrder
        .filter((mode) => grouped[mode]?.length > 0)
        .map((mode) => (
          <List.Section
            key={mode}
            title={`${MODE_EMOJIS[mode] || ""} ${MODE_NAMES[mode] || mode}`}
          >
            {grouped[mode].map((binding, index) => (
              <List.Item
                key={`${mode}-${index}`}
                title={binding.key}
                subtitle={binding.description}
                icon={binding.isModeSwitch ? Icon.ArrowRight : Icon.Keyboard}
                actions={
                  <ActionPanel>
                    <Action
                      title="Execute Binding"
                      icon={Icon.Play}
                      onAction={() => executeBinding(binding)}
                    />
                    <Action.CopyToClipboard
                      title="Copy Key"
                      content={binding.key}
                      shortcut={{ modifiers: ["cmd"], key: "c" }}
                    />
                  </ActionPanel>
                }
              />
            ))}
          </List.Section>
        ))}
    </List>
  );
}
