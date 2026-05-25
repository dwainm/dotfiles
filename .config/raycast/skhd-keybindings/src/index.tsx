import React, { useState, useEffect } from "react";
import { List, ActionPanel, Action, Icon, showToast, Toast } from "@raycast/api";
import { execSync } from "child_process";
import { readFileSync } from "fs";

interface Binding {
  mode: string;
  key: string;
  description: string;
  isModeSwitch: boolean;
  rawLine: string;
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
  switch (key) {
    case "0x1B": return "-";
    case "0x18": return "=";
    case "0x1E": return "]";
    case "0x21": return "[";
    case "0x2A": return "\\";
    default: return key;
  }
}

function parseSkhdrc(path: string): Binding[] {
  const content = readFileSync(path, "utf-8");
  const lines = content.split("\n");
  const bindings: Binding[] = [];

  for (const line of lines) {
    const trimmed = line.trim();
    if (!trimmed || trimmed.startsWith("#")) continue;
    if (!trimmed.includes(";;info:")) continue;

    const infoMatch = trimmed.match(/;;info:\s*(.+)$/);
    if (!infoMatch) continue;
    const description = infoMatch[1];

    // Check if it's a mode declaration line
    if (trimmed.startsWith("::")) continue;

    // Mode-specific binding: mode < key : command or mode < key ; dest
    const modeMatch = trimmed.match(/^([a-z]+)\s*<\s*(.+?)(?:\s*[:;]\s*)/);
    if (modeMatch) {
      const mode = modeMatch[1];
      let key = modeMatch[2].trim();
      key = resolveHexKey(key);
      const isModeSwitch = trimmed.includes(";;info: switch to") || trimmed.includes(";;info: enter") || trimmed.includes(";;info: return to") || trimmed.includes(";;info: go to") || (trimmed.includes(" ; ") && !trimmed.includes(" : "));
      bindings.push({ mode, key, description, isModeSwitch, rawLine: trimmed });
      continue;
    }

    // Global binding (default mode)
    // ctrl - h [ ;;info: desc
    // ctrl - f : command ;;info: desc
    // shift + ctrl + alt + cmd - b ; break ;;info: desc
    const blockMatch = trimmed.match(/^(.+?)\s*\[\s*;;info:/);
    if (blockMatch) {
      const key = blockMatch[1].trim();
      bindings.push({ mode: "default", key, description, isModeSwitch: false, rawLine: trimmed });
      continue;
    }

    const globalMatch = trimmed.match(/^(.+?)\s*(?:[:;])\s*/);
    if (globalMatch) {
      const key = globalMatch[1].trim();
      const isModeSwitch = trimmed.includes(" ; ") && !trimmed.includes(" : ");
      bindings.push({ mode: "default", key, description, isModeSwitch, rawLine: trimmed });
    }
  }

  return bindings;
}

function executeBinding(binding: Binding) {
  try {
    if (binding.isModeSwitch) {
      // For mode switches, we need to trigger the key in the context of the mode
      execSync(`skhd -k "${binding.key}"`, { timeout: 5000 });
      showToast({ style: Toast.Style.Success, title: `Switched: ${binding.description}` });
    } else {
      execSync(`skhd -k "${binding.key}"`, { timeout: 5000 });
      showToast({ style: Toast.Style.Success, title: `Executed: ${binding.description}` });
    }
  } catch (error) {
    showToast({ style: Toast.Style.Failure, title: "Failed to execute binding", message: String(error) });
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

  // Group bindings by mode
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
                title={`${binding.key}`}
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
