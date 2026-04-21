local colors = require("colors")
local settings = require("settings")

local popup_width = 120

-- Pomodoro timer widget
local pomodoro = sbar.add("item", "widgets.pomodoro", {
  position = "right",
  background = {
    height = 22,
    color = { alpha = 0 },
    border_color = { alpha = 0 },
    drawing = true,
  },
  icon = {
    string = "⏱",
    color = colors.grey,
    font = { family = settings.font.text, style = settings.font.style_map["Regular"], size = 14.0 },
  },
  label = {
    string = "",
    color = colors.white,
    font = { family = "SF Mono", style = settings.font.style_map["Bold"], size = 9.0 },
    align = "right",
    padding_right = 0,
    y_offset = 4,
  },
  update_freq = 1,
  padding_right = settings.paddings,
  popup = { align = "center", height = 30 },
})

-- Popup menu items
local menu_items = {
  { label = "5 min", cmd = "~/.local/bin/pomodoro start 5" },
  { label = "10 min", cmd = "~/.local/bin/pomodoro start 10" },
  { label = "30 min", cmd = "~/.local/bin/pomodoro start 30" },
  { label = "45 min", cmd = "~/.local/bin/pomodoro start 45" },
  { label = "Reset", cmd = "~/.local/bin/pomodoro reset" },
  { label = "Break now", cmd = "~/.local/bin/pomodoro break" },
}

for _, item in ipairs(menu_items) do
  sbar.add("item", {
    position = "popup." .. pomodoro.name,
    label = {
      string = item.label,
      font = { size = 12 },
    },
    icon = { drawing = false },
    width = popup_width,
    align = "center",
    click_script = item.cmd .. " && sketchybar --set " .. pomodoro.name .. " popup.drawing=off && sketchybar --trigger forced",
  })
end

-- Update pomodoro status
pomodoro:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("~/.local/bin/pomodoro mode 2>/dev/null", function(mode_result)
    local mode = mode_result:gsub("^%s*(.-)%s*$", "%1")

    if mode == "break" then
      -- Break mode - hide icon, show elapsed time counting up
      sbar.exec("~/.local/bin/pomodoro break-elapsed 2>/dev/null", function(elapsed)
        local elapsed_time = elapsed:gsub("^%s*(.-)%s*$", "%1")
        pomodoro:set({
          icon = { string = "", color = colors.transparent },
          label = { string = elapsed_time, color = colors.yellow },
        })
      end)
    else
      sbar.exec("~/.local/bin/pomodoro status 2>/dev/null", function(result)
        local output = result:gsub("^%s*(.-)%s*$", "%1")

        if output == "" then
          -- Not running - grey icon, "OFF" label
          pomodoro:set({
            icon = { string = "⏱", color = colors.grey },
            label = { string = "OFF", color = colors.grey },
          })
        else
          -- Running - green icon, time remaining
          pomodoro:set({
            icon = { string = "⏱", color = colors.green },
            label = { string = output, color = colors.white },
          })
        end
      end)
    end
  end)
end)

-- Left click to toggle start/stop, right click for menu
pomodoro:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    pomodoro:set({ popup = { drawing = "toggle" } })
  else
    sbar.exec("if [ -f ~/.config/pomo/state ]; then ~/.local/bin/pomodoro stop; else ~/.local/bin/pomodoro start 40; fi")
    sbar.trigger("forced")
  end
end)

-- Hide popup when mouse exits
pomodoro:subscribe("mouse.exited.global", function(env)
  pomodoro:set({ popup = { drawing = false } })
end)

-- Background bracket
sbar.add("bracket", "widgets.pomodoro.bracket", { pomodoro.name }, {
  background = { color = colors.bg1 }
})

-- Padding
sbar.add("item", "widgets.pomodoro.padding", {
  position = "right",
  width = settings.group_paddings
})

