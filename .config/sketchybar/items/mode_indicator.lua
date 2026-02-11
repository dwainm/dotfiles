local colors = require("colors")
local settings = require("settings")

-- Mode indicator item (positioned on right to avoid notch)
local mode_indicator = sbar.add("item", "mode_indicator", {
  position = "right",
  background = {
    color = colors.transparent,
    padding_left = 0,
    padding_right = 0,
    border_width = 0,
  },
  icon = {
    string = "●",
    color = colors.white,
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 16.0 },
    background = { color = colors.transparent, border_width = 0 },
  },
  label = {
    string = "",
    color = colors.transparent,
  },
  padding_left = 0,
  padding_right = 0,
})

-- Background bracket for popup
local mode_bracket = sbar.add("bracket", "mode_indicator.bracket", {
  mode_indicator.name,
}, {
  background = { color = colors.transparent },
  popup = { align = "center", height = 30 }
})

local popup_width = 320

-- Mode title
local mode_title = sbar.add("item", "mode_indicator.title", {
  position = "popup." .. mode_bracket.name,
  icon = {
    font = { style = settings.font.style_map["Bold"] },
    string = "🎯",
  },
  width = popup_width,
  align = "center",
  label = {
    font = { size = 14, style = settings.font.style_map["Bold"] },
    string = "NORMAL MODE",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -10
  }
})

-- Mode-specific shortcuts data
local mode_shortcuts = {
  NORMAL = {
    icon = "🎯",
    title = "NORMAL MODE",
    shortcuts = {
      { key = "ctrl+h/j/k/l", desc = "Focus prev/down/up/next" },
      { key = "ctrl+f", desc = "Toggle fullscreen" },
      { key = "cmd+ctrl+q/w/f/p/g", desc = "Switch workspace" },
      { key = "cmd+space", desc = "Launcher mode" }
    }
  },
  SERVICE = {
    icon = "⚙️",
    title = "SERVICE MODE",
    shortcuts = {
      { key = "r", desc = "Reload AeroSpace config" },
      { key = "esc", desc = "Back to normal mode" }
    }
  },
  WORKSPACE = {
    icon = "🏢",
    title = "WORKSPACE MODE",
    shortcuts = {
      { key = "h/j/k/l", desc = "Move window" },
      { key = "shift+h/j/k/l", desc = "Join with adjacent" },
      { key = "alt+t/a", desc = "Tiles/Accordion layout" },
      { key = "alt+h/v", desc = "H/V accordion" },
      { key = "alt+space", desc = "Toggle floating" },
      { key = "0", desc = "Float all (old way)" },
      { key = "s/shift+s", desc = "Split H/V" },
      { key = "-/=", desc = "Resize smaller/larger" },
      { key = "q/w/f/p/g", desc = "Switch workspace" },
      { key = "shift+q/w/f/p/g", desc = "Move window + follow" },
      { key = "alt+backspace", desc = "Close all but current" },
      { key = "esc", desc = "Back to normal" }
    }
  },
  LINK = {
    icon = "🔗",
    title = "LINK MODE",
    shortcuts = {
      { key = "x", desc = "Open X/Twitter" },
      { key = "shift+x", desc = "Your X profile" },
      { key = "p", desc = "Klop PRs" },
      { key = "i", desc = "Klop Issues" },
      { key = "g", desc = "Gmail in Safari" },
      { key = "shift+g", desc = "Grok in Safari" },
      { key = "shift+k", desc = "Klop production" },
      { key = "y", desc = "Hacker News" },
      { key = "esc", desc = "Back to normal" }
    }
  },
  LAUNCHER = {
    icon = "🚀",
    title = "LAUNCHER MODE",
    shortcuts = {
      { key = "l", desc = "Link mode" },
      { key = "w", desc = "Workspace mode" },
      { key = "i", desc = "Writing mode" },
      { key = "[/]", desc = "Prev/next workspace" },
      { key = "\\", desc = "Focus back and forth" },
      { key = "a", desc = "AI tmux window" },
      { key = "o", desc = "Obsidian" },
      { key = "r", desc = "Raycast" },
      { key = "b", desc = "Safari (workspace q)" },
      { key = "s", desc = "Safari (workspace g)" },
      { key = "c", desc = "Calendar" },
      { key = "m", desc = "Mail" },
      { key = "d", desc = "System Settings" },
      { key = "k", desc = "Kitty terminal" },
      { key = "v", desc = "Vim window" },
      { key = "t", desc = "Terminal window" },
      { key = "n", desc = "Start pomodoro (40m)" },
      { key = "esc", desc = "Back to normal" }
    }
  },
  INSERT = {
    icon = "✍️",
    title = "INSERT MODE - Distraction-Free Writing",
    shortcuts = {
      { key = "esc", desc = "Exit insert mode" },
      { key = "No shortcuts", desc = "All modifiers disabled" },
      { key = "Pure typing", desc = "Focus on writing" }
    }
  },
  MUX = {
    icon = "🖥️",
    title = "MUX MODE - Tmux Operations",
    shortcuts = {
      { key = "t", desc = "Fuzzy session switcher" },
      { key = "s", desc = "Choose tree (sessions)" },
      { key = ";", desc = "Tmux command mode" },
      { key = "double-tap N", desc = "Back to launcher" },
      { key = "esc", desc = "Back to normal" }
    }
  },
  BREAK = {
    icon = "☕",
    title = "BREAK MODE - Take a break!",
    shortcuts = {
      { key = "esc", desc = "End break, start new pomodoro" },
      { key = "return", desc = "Back to normal" }
    }
  }
}

-- Find max shortcuts count for pool size
local max_shortcuts = 0
for _, data in pairs(mode_shortcuts) do
  if #data.shortcuts > max_shortcuts then
    max_shortcuts = #data.shortcuts
  end
end

-- Pre-create pool of popup items (reused across mode changes)
local popup_items = {}
for i = 1, max_shortcuts do
  local item = sbar.add("item", "mode_indicator.shortcut." .. i, {
    position = "popup." .. mode_bracket.name,
    drawing = false,
    icon = {
      align = "left",
      string = "",
      width = popup_width / 2,
      font = { family = "SF Mono", size = 9, style = settings.font.style_map["Bold"] }
    },
    label = {
      string = "",
      width = popup_width / 2,
      align = "left",
      font = { size = 9 }
    }
  })
  popup_items[i] = item
end

-- Update popup items for a given mode (reuses existing items)
local function update_popup_items(mode)
  local data = mode_shortcuts[mode] or mode_shortcuts.NORMAL

  -- Update title
  mode_title:set({
    icon = { string = data.icon },
    label = { string = data.title }
  })

  -- Update/show items for current mode's shortcuts
  for i, item in ipairs(popup_items) do
    local shortcut = data.shortcuts[i]
    if shortcut then
      item:set({
        drawing = true,
        icon = { string = shortcut.key },
        label = { string = shortcut.desc }
      })
    else
      item:set({ drawing = false })
    end
  end
end

-- Icon and color maps
local icon_map = {
  NORMAL = "●",
  SERVICE = "⚙️",
  WORKSPACE = "🏢",
  LINK = "🔗",
  LAUNCHER = "🚀",
  INSERT = "✍️",
  MUX = "🖥️",
  BREAK = "☕"
}

local bar_colors = {
  NORMAL = 0xf02c2e34,
  SERVICE = 0xf09ed072,
  WORKSPACE = 0xf076cce0,
  LINK = 0xf0ff6b9d,
  LAUNCHER = 0xf0ff9500,
  INSERT = 0xf0ffffff,
  MUX = 0xf0a855f7,
  BREAK = 0xf09ed072
}

-- Subscribe to mode changes
mode_indicator:subscribe({ "mode_change", "routine" }, function(env)
  local mode = env.MODE or "NORMAL"

  mode_indicator:set({
    icon = { string = icon_map[mode] or "🎯", color = colors.white },
    label = { string = "" }
  })

  update_popup_items(mode)
  sbar.bar({ color = bar_colors[mode] or bar_colors.NORMAL })
end)

-- Popup toggle functions
local function hide_shortcuts()
  mode_bracket:set({ popup = { drawing = false } })
end

local function toggle_shortcuts()
  local should_draw = mode_bracket:query().popup.drawing == "off"
  mode_bracket:set({ popup = { drawing = should_draw } })
end

-- Initialize with NORMAL mode
update_popup_items("NORMAL")

-- Click handlers
mode_indicator:subscribe("mouse.clicked", toggle_shortcuts)
mode_indicator:subscribe("mouse.exited.global", hide_shortcuts)
