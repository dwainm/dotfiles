#!/bin/bash
# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.hideDisable>true</swiftbar.hideDisable>
# <swiftbar.hideSwiftBar>true</swiftbar.hideSwiftBar>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>

SKHD_RC="$HOME/.config/skhd/skhdrc"

mode=$(cat /tmp/skhd_mode 2>/dev/null || echo "default")

case "$mode" in
  default)   emoji="⌨️"  ; name="Default" ;;
  service)   emoji="🔧"  ; name="Service" ;;
  workspace) emoji="🖥️"  ; name="Workspace" ;;
  launcher)  emoji="🚀"  ; name="Launcher" ;;
  writing)   emoji="✍️"  ; name="Writing" ;;
  break)     emoji="☕"   ; name="Break" ;;
  *)         emoji="❓"   ; name="?" ;;
esac

echo "$emoji $name"
echo "---"

resolve_key() {
  echo "$1" | sed 's/0x1B/-/g; s/0x18/=/g; s/0x1E/]/g; s/0x21/[/g; s/0x2A/\\/g'
}

echo_item() {
  local key="$1"
  local info="$2"
  key=$(resolve_key "$key")
  if [[ "$key" == "-" ]]; then
    echo "-- minus  $info"
  else
    echo "--$key  $info"
  fi
}

# Parse skhdrc: track pending comments and associate them with bindings
parse_bindings() {
  local current_mode="default"
  local pending_comment=""
  local in_block=0

  while IFS= read -r line; do
    # Track mode declarations
    if [[ "$line" =~ ^::[[:space:]]+([a-z]+) ]]; then
      current_mode="${BASH_REMATCH[1]}"
      pending_comment=""
      continue
    fi

    # Empty line resets pending comment
    if [[ -z "$line" ]]; then
      pending_comment=""
      continue
    fi

    # Capture comment lines (but not section headers)
    if [[ "$line" =~ ^#[[:space:]]+(.+) ]]; then
      local comment="${BASH_REMATCH[1]}"
      if [[ ! "$comment" =~ ^[-=]+ ]] && [[ ! "$comment" =~ ^[0-9]+\. ]]; then
        pending_comment="$comment"
      fi
      continue
    fi

    # Skip lines without a pending comment
    [[ -z "$pending_comment" ]] && continue

    # Skip lines that are just comments (no binding)
    [[ "$line" =~ ^[[:space:]]*# ]] && { pending_comment=""; continue; }

    local info="$pending_comment"

    # Handle multi-line blocks
    if [[ "$line" =~ ^[[:space:]]*\* ]] || [[ "$line" =~ ^\" ]] || [[ "$line" =~ ^\] ]]; then
      if [[ "$line" =~ ^\] ]]; then
        in_block=0
      fi
      pending_comment=""
      continue
    fi

    # Mode-specific bindings: mode < key
    if [[ "$line" =~ ^([a-z]+)[[:space:]]*\<[[:space:]]*(.+) ]]; then
      local m="${BASH_REMATCH[1]}"
      local rest="${BASH_REMATCH[2]}"
      local key
      key=$(echo "$rest" | sed 's/[[:space:]]*[:;].*//' | sed 's/[[:space:]]*$//')
      echo "MODE:$m|$key|$info"
      pending_comment=""
      continue
    fi

    # Global bindings
    local key_part
    key_part=$(echo "$line" | sed 's/[[:space:]]*[:;].*//' | sed 's/[[:space:]]*\[.*//')
    [[ -z "$key_part" ]] && { pending_comment=""; continue; }

    local key
    key=$(echo "$key_part" | awk '{print $NF}')
    local modifiers
    modifiers=$(echo "$key_part" | sed "s/[[:space:]]*${key}$//")
    modifiers=$(echo "$modifiers" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')

    if [[ -n "$modifiers" ]]; then
      echo "MODE:default|$modifiers $key|$info"
    else
      echo "MODE:default|$key|$info"
    fi

    pending_comment=""
  done < "$SKHD_RC"
}

if [ "$mode" != "default" ]; then
  parse_bindings | grep "^MODE:$mode|" | while IFS='|' read -r _ key info; do
    echo_item "$key" "$info"
  done
else
  parse_bindings | grep "^MODE:default|" | while IFS='|' read -r _ key info; do
    echo_item "$key" "$info"
  done
fi

if [ "$mode" != "default" ]; then
  echo "---"
  echo "--esc  return to default mode | bash=\"skhd -k escape\" terminal=false refresh=true"
fi
