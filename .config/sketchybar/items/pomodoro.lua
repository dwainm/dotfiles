local colors = require("colors")
local settings = require("settings")

-- Pomodoro timer widget (positioned left of mode indicator)
local pomodoro = sbar.add("item", "pomodoro", {
  position = "right",
  background = {
    color = colors.transparent,
    padding_left = 0,
    padding_right = 8,
  },
  icon = {
    string = "",
    color = colors.white,
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 12.0 },
  },
  label = {
    string = "",
    color = colors.white,
    font = { family = "SF Mono", style = settings.font.style_map["Regular"], size = 12.0 },
  },
  update_freq = 1,
})

-- Update pomodoro status
pomodoro:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("pomodoro status 2>/dev/null", function(result)
    local output = result:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace

    if output == "" then
      pomodoro:set({
        icon = { string = "" },
        label = { string = "" },
      })
    else
      pomodoro:set({
        icon = { string = "⏱", color = colors.white },
        label = { string = output, color = colors.white },
      })
    end
  end)
end)
