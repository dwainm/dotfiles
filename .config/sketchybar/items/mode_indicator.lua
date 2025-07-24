local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Mode indicator item (positioned on right to avoid notch)
sbar.add("item", "mode_indicator", {
  position = "right", 
  background = {
    color = colors.transparent,
    padding_left = 8,
    padding_right = 8,
  },
  icon = {
    string = "●",
    color = colors.white,
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 16.0 },
  },
  label = {
    string = "",  -- No label, just icon
    color = colors.transparent,
  },
  padding_left = 5,
  padding_right = 5,
})

-- Subscribe to custom events for mode changes
sbar.subscribe("mode_indicator", { "mode_change", "routine" }, function(env)
  local mode = env.MODE or "NORMAL"
  local icon_map = {
    NORMAL = "●",
    SERVICE = "⚙️", 
    WORKSPACE = "🏢",
    LINK = "🔗"
  }
  
  -- Define bar background colors for each mode
  local bar_colors = {
    NORMAL = 0xf02c2e34,      -- current default color
    SERVICE = 0xf09ed072,     -- shade of green  
    WORKSPACE = 0xf076cce0,   -- tint of blue
    LINK = 0xf0ff6b9d         -- bright pink/magenta for links
  }
  
  -- Update the mode indicator icon
  sbar.set("mode_indicator", {
    icon = { string = icon_map[mode] or "🎯", color = colors.white },
    label = { string = "" }  -- Keep label empty
  })
  
  -- Change the entire bar background color
  sbar.bar({ color = bar_colors[mode] or bar_colors.NORMAL })
end)