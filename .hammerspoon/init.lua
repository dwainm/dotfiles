local hyper       = {"cmd","alt","ctrl"}
local shift_hyper = {"cmd","alt","ctrl","shift"}
local ctrl_cmd    = {"cmd","ctrl"}

local logger = hs.logger.new("d", "debug")

-- Screens
macbook_monitor = "Built-in Retina Display"
main_monitor = "LG UltraFine"


-- Logging

-- Configuring layouts
-- API works in percentages 0.333 = 33.3%
local position = {
    maximized = hs.layout.maximized,
    -- Centered
    centered              = {x=0.15, y=0.15, w=0.7, h=0.7},
    centerThirdHalfTop    = {x=0.333, y=0, w=0.333, h=0.5},
    centerThirdHalfBottom = {x=0.333, y=0.5, w=0.333, h=0.5},
    centerThirdFulllength = {x=0.333, y=0, w=0.333, h=1},

    -- Left and Right
    left34 = {x=0, y=0, w=0.34, h=1},
    left50 = hs.layout.left50,
    left66 = {x=0, y=0, w=0.66, h=1},
    left70 = hs.layout.left70,
    right30 = hs.layout.right30,
    rightThird = {x=0.666, y=0, w=0.333, h=1},
    leftThird = {x=0, y=0, w=0.333, h=1},
    right34 = {x=0.66, y=0, w=0.34, h=1},
    right50 = hs.layout.right50,
    right66 = {x=0.34, y=0, w=0.66, h=1},
    -- Up and down
    upper50 = {x=0, y=0, w=1, h=0.5},
    upper50Left50 = {x=0, y=0, w=0.5, h=0.5},
    upper50Right15 = {x=0.85, y=0, w=0.15, h=0.5},
    upper50Right30 = {x=0.7, y=0, w=0.3, h=0.5},
    upper50Right50 = {x=0.5, y=0, w=0.5, h=0.5},
    lower50 = {x=0, y=0.5, w=1, h=0.5},
    lower50Left50 = {x=0, y=0.5, w=0.5, h=0.5},
    lower50Right50 = {x=0.5, y=0.5, w=0.5, h=0.5},
}


-- A layout for code related tasks, like PR reviews and code modification
local coding_layout= {
  {"Terminal",      nil, macbook_monitor, position.maximized, nil, nil},
  {"Google Chrome", nil, main_monitor,    position.left50,    nil, nil},
  {"Emacs",         nil, main_monitor,    position.right50,   nil, nil},
  {"Station",       nil, second_monitor,  position.left50,    nil, nil},
  {"TablePlus",     nil, second_monitor,  position.right50,   nil, nil},
}

-- A layout for communication tasks, which includes reading
local comms_layout = {
  {"Terminal",      nil, macbook_monitor, position.maximized, nil, nil},
  {"Google Chrome", nil, main_monitor,    position.left50,    nil, nil},
  {"Emacs",         nil, main_monitor,    position.right50,   nil, nil},
  {"Station",       nil, second_monitor,  position.left50,    nil, nil},
  {"TablePlus",     nil, second_monitor,  position.right50,   nil, nil},
}

--
-- Layout for objective planning
--
hs.hotkey.bind(hyper, '1', function()

-- A layout for communication tasks, which includes reading
local objectiveLayout = {
    {"Google Chrome", "Calendar", main_monitor, position.leftThird,    nil, nil},
    {"Google Chrome", "Objectives", main_monitor, position.centerThirdFulllength,    nil, nil},
    {"Google Chrome", "Outcomes", main_monitor,    position.rightThird,    nil, nil},
}

  hs.application.launchOrFocus('Google Chrome')

  hs.urlevent.openURL("https://www.notion.so/dd0bd03cac0b4cd2803962996024abe4?v=6221b429a53748ec9886f32644b21186")

  newWindow("Google Chrome")
  hs.urlevent.openURL("https://www.notion.so/cba3bd56b12a423cbd4de60503679f57?v=1266e77586a94b27b7450e2dfe803ff8")

  newWindow("Google Chrome")
  hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")


  hs.timer.doAfter(3, function()
      hs.layout.apply(objectiveLayout, TitleComparitor)
  end)
end)


-- A layout for doing 1on1s.
local one_on_one_layout= {
    -- {"kitty",         nil, macbook_monitor, hs.layout.left50, nil, nil},
    {"Google Chrome", "Google Meet", main_monitor,    position.centerThirdHalfTop,    nil, nil},
    {"Google Chrome", "New Tab", main_monitor,    position.rightThird,    nil, nil},
    {"Slack",         nil, main_monitor,    position.centerThirdHalfBottom,   nil, nil},
}

hs.hotkey.bind(hyper, '3', function()
  hs.application.launchOrFocus('kitty')
  hs.application.launchOrFocus('Slack')
  hs.application.launchOrFocus('Google Chrome')
  hs.urlevent.openURL("https://meet.google.com/")
  newWindow("Google Chrome")

  hs.timer.doAfter(2, applyLayout)

  -- Todo
  -- One one for each person ( a popup po ask who this session is for )
  -- jump directly to the persons doc and slack channel
end)

function applyLayout()
  hs.layout.apply(one_on_one_layout, TitleComparitor)
end

function newWindow(appId) 
    local app = hs.application.find(appId)
    app:selectMenuItem({"File", "New Window"})
end

TitleComparitor = function (a,b)
    logger.i('comparing')
    logger.i(a)
    logger.i(b)
    logger.i(b==string.match(a, b))
    return b==string.match(a, b)
end
