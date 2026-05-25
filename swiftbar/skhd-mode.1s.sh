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
  case "$1" in
    "0x1B") echo "-" ;;
    "0x18") echo "=" ;;
    "0x1E") echo "]" ;;
    "0x21") echo "[" ;;
    "0x2A") echo "\\" ;;
    *) echo "$1" ;;
  esac
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

if [ "$mode" != "default" ]; then
  grep "^$mode <" "$SKHD_RC" | grep ";;info:" | while IFS= read -r line; do
    rest="${line#*<}"
    rest="${rest# }"
    key="${rest%% [;:]*}"
    info="${line#*;;info: }"
    echo_item "$key" "$info"
  done
else
  grep -v -E "^(::|[a-z]+\s+<)" "$SKHD_RC" | grep ";;info:" | while IFS= read -r line; do
    if [[ "$line" == *" [ ;;"* ]]; then
      key="${line%% \[*}"
    else
      key="${line%% [;:]*}"
    fi
    info="${line#*;;info: }"
    echo_item "$key" "$info"
  done
fi

if [ "$mode" != "default" ]; then
  echo "---"
  echo "--esc  return to default mode | bash=\"skhd -k escape\" terminal=false refresh=true"
fi
