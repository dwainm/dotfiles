local settings = require("settings")
local colors = require("colors")

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 49,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "right",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1
  },
  click_script = "open -a 'Calendar'"
})

-- Double border for calendar using a single item bracket
sbar.add("bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_color = colors.grey,
  }
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  -- Format: "Wed 18th" with proper suffix
  local day = tonumber(os.date("%d"))
  local suffix = "th"
  if day % 10 == 1 and day ~= 11 then
    suffix = "st"
  elseif day % 10 == 2 and day ~= 12 then
    suffix = "nd"
  elseif day % 10 == 3 and day ~= 13 then
    suffix = "rd"
  end
  local date_str = os.date("%a ") .. day .. suffix
  cal:set({ icon = date_str, label = os.date("%H:%M") })
end)
