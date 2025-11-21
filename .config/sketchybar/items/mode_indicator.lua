local colors = require("colors")
local icons = require("icons")
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
    string = "",  -- No label, just icon
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
local mode_title = sbar.add("item", {
  position = "popup." .. mode_bracket.name,
  icon = {
    font = {
      style = settings.font.style_map["Bold"]
    },
    string = "🎯",
  },
  width = popup_width,
  align = "center",
  label = {
    font = {
      size = 14,
      style = settings.font.style_map["Bold"]
    },
    string = "NORMAL MODE",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -10
  }
})

-- Dynamic popup items (will be created based on mode)
local popup_items = {}

-- Mode-specific shortcuts data
local mode_shortcuts = {
  NORMAL = {
    icon = "🎯",
    title = "NORMAL MODE",
    shortcuts = {
      { key = "ctrl+h/j/k/l", desc = "Focus left/down/up/right" },
      { key = "ctrl+f", desc = "Toggle fullscreen" },
      { key = "ctrl+cmd+c", desc = "Open Chrome" },
      { key = "ctrl+m", desc = "Dropdown terminal" },
      { key = "double-tap N", desc = "Launcher mode" }
    }
  },
  SERVICE = {
    icon = "⚙️",
    title = "SERVICE MODE",
    shortcuts = {
      { key = "r", desc = "Reload AeroSpace config" },
      { key = "f", desc = "Flatten workspace tree" },
      { key = "double-tap N", desc = "Back to launcher" },
      { key = "esc", desc = "Back to normal mode" }
    }
  },
  WORKSPACE = {
    icon = "🏢",
    title = "WORKSPACE MODE",
    shortcuts = {
      { key = "h/j/k/l", desc = "Move window" },
      { key = "shift+h/j/k/l", desc = "Join with adjacent" },
      { key = "alt+t", desc = "Tiles layout" },
      { key = "alt+a", desc = "Accordion layout" },
      { key = "alt+h/v", desc = "H/V accordion" },
      { key = "alt+space", desc = "Toggle floating" },
      { key = "s/shift+s", desc = "Split H/V" },
      { key = "f", desc = "Flatten workspace" },
      { key = "-", desc = "Resize smaller" },
      { key = "=", desc = "Resize larger" },
      { key = "shift+-", desc = "Resize smaller (2x)" },
      { key = "shift+=", desc = "Resize larger (2x)" },
      { key = "q/w/f/p/g", desc = "Switch workspace" },
      { key = "shift+q/w/f/p/g", desc = "Move window + follow" },
      { key = "double-tap N", desc = "Back to launcher" },
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
      { key = "shift+k", desc = "Klop production" },
      { key = "y", desc = "Hacker News" },
      { key = "double-tap N", desc = "Back to launcher" },
      { key = "esc", desc = "Back to normal" }
    }
  },
  LAUNCHER = {
    icon = "🚀",
    title = "LAUNCHER MODE",
    shortcuts = {
      { key = "l", desc = "Link mode" },
      { key = "w", desc = "Workspace mode" },
      { key = ";", desc = "Service mode" },
      { key = "i", desc = "Writing mode" },
      { key = "a", desc = "Alacritty terminal" },
      { key = "p", desc = "Basecamp" },
      { key = "o", desc = "Obsidian" },
      { key = "r", desc = "Raycast" },
      { key = "b", desc = "Safari browser" },
      { key = "m", desc = "Music" },
      { key = "d", desc = "System Settings" },
      { key = "k", desc = "Kitty terminal" },
      { key = "v", desc = "Kitty vim pane" },
      { key = "t", desc = "Kitty terminal pane" },
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
      { key = "esc", desc = "End break, start new work session" }
    }
  }
}

-- Function to clear existing popup items
local function clear_popup_items()
  for _, item in ipairs(popup_items) do
    sbar.remove(item.name)
  end
  popup_items = {}
end

-- Function to create popup items for shortcuts
local function create_popup_items(mode)
  clear_popup_items()
  
  local data = mode_shortcuts[mode] or mode_shortcuts.NORMAL
  
  -- Update title
  mode_title:set({
    icon = { string = data.icon },
    label = { string = data.title }
  })
  
  -- Create individual items for each shortcut
  for i, shortcut in ipairs(data.shortcuts) do
    local item = sbar.add("item", {
      position = "popup." .. mode_bracket.name,
      icon = {
        align = "left",
        string = shortcut.key,
        width = popup_width / 2,
        font = { family = "SF Mono", size = 9, style = settings.font.style_map["Bold"] }
      },
      label = {
        string = shortcut.desc,
        width = popup_width / 2,
        align = "left",
        font = { size = 9 }
      }
    })
    table.insert(popup_items, item)
  end
end

-- Subscribe to custom events for mode changes
sbar.subscribe("mode_indicator", { "mode_change", "routine" }, function(env)
  local mode = env.MODE or "NORMAL"
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

  -- Define bar background colors for each mode
  local bar_colors = {
    NORMAL = 0xf02c2e34,      -- current default color
    SERVICE = 0xf09ed072,     -- shade of green
    WORKSPACE = 0xf076cce0,   -- tint of blue
    LINK = 0xf0ff6b9d,        -- bright pink/magenta for links
    LAUNCHER = 0xf0ff9500,    -- orange for launcher
    INSERT = 0xf0ffffff,      -- white for insert/writing mode
    MUX = 0xf0a855f7,         -- purple for mux/tmux mode
    BREAK = 0xf09ed072        -- green for break mode
  }
  
  -- Update the mode indicator icon
  mode_indicator:set({
    icon = { string = icon_map[mode] or "🎯", color = colors.white },
    label = { string = "" }  -- Keep label empty
  })
  
  -- Create popup items for current mode
  create_popup_items(mode)
  
  -- Change the entire bar background color
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

-- Initialize with NORMAL mode shortcuts
create_popup_items("NORMAL")

-- Add click handlers
mode_indicator:subscribe("mouse.clicked", toggle_shortcuts)
mode_indicator:subscribe("mouse.exited.global", hide_shortcuts)