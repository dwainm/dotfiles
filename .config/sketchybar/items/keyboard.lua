local settings = require("settings")
local colors = require("colors")

-- Keyboard layout indicator
local keyboard = sbar.add("item", "keyboard", {
  position = "right",
  icon = {
    string = "⌨️",
    color = colors.white,
    font = { size = 12 },
  },
  label = {
    string = "ABC",
    color = colors.white,
    font = { family = settings.font.numbers, size = 12 },
  },
  padding_left = 8,
  padding_right = 8,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1,
    height = 24,
  },
  click_script = "~/.config/sketchybar/helpers/keyboard_layout.sh switch"
})

-- Double border for keyboard using bracket
sbar.add("bracket", { keyboard.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_color = colors.grey,
  }
})

-- Update keyboard layout display
local function update_keyboard_layout()
  local handle = io.popen("~/.config/sketchybar/helpers/keyboard_layout.sh get")
  local layout = handle:read("*a"):gsub("%s+$", "")
  handle:close()
  
  -- Shorten layout names for display
  local short_names = {
    ABC = "ABC",
    Colemak = "CMK",
    Dvorak = "DVK",
    ["U.S."] = "US",
    ["U.S. International"] = "USI",
  }
  
  local display = short_names[layout] or layout:sub(1, 3):upper()
  keyboard:set({ label = { string = display } })
end

-- Subscribe to updates
keyboard:subscribe({ "forced", "routine", "system_woke" }, function(env)
  update_keyboard_layout()
end)

-- Initial update
update_keyboard_layout()
