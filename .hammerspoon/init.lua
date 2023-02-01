local hyper       = {"cmd","alt","ctrl"}
local shift_hyper = {"cmd","alt","ctrl","shift"}
local ctrl_cmd    = {"cmd","ctrl"}
local alt_cmd    = {"alt","cmd"}

local logger = hs.logger.new("d", "debug")

function reloadConfig(files)
    doReload = false
    for _,file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()


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
    centered60Top         = {x=0.15, y=0, w=0.7, h=0.6},
    centered55Top         = {x=0.15, y=0, w=0.7, h=0.55},
    centered45Bottom      = {x=0.15, y=0.55, w=0.7, h=0.45},
    centered40Bottom      = {x=0.15, y=0.6, w=0.7, h=0.4},
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

Init = function ()
    -- Table to itterate over with modieier, key and function to call after it is pressed.
    local layoutBindings = {
        {"0" , CalendarSlack, "Initialize"},
        {"1" , planningLayout, "Planning"},
        {"2" , SlackP2, "Slack p2"},
        {"3" , OneOnOne, "1on1"},
        {"4" , SprintManagement, "Sprint Management"},
        {"8" , CommsLayout, "Commms"},
        {"9" , closingTheday, "Closing The day"},
    }

    for index, layout in pairs(layoutBindings) do
        hs.hotkey.bind( hyper,layout[1],layout[2])
    end
    return layoutBindings
end

SprintManagement = function ()

    CloseAllWindows()

    local layout = {
        {"Slack", nil, main_monitor,    position.centered60Top,    nil, nil},
        {"Google Chrome", "Sprints", macbook_monitor, position.right50,    nil, nil},
        {"Google Chrome", "#sprint", main_monitor, position.right50,    nil, nil},
        {"Google Chrome", "Sigma Planner", main_monitor, position.left50,    nil, nil},
    }

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

    hs.urlevent.openURL("https://docs.google.com/spreadsheets/d/1_ruX4wG0p30tzXKZcRmQ4g32SYeNMUz3hfKEg2g9M-4/edit#gid=0")
    hs.urlevent.openURL("https://app.zenhub.com/workspaces/sigma-team-605211b24a30720013d5f43f/reports/burndown")
    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://howdysigma.wordpress.com/tag/sprint/")
    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://howdysigma.wordpress.com/sprints/#weekly-responsibilities")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end

CalendarSlack = function ()
    CloseAllWindows()

    local layout = {
        {"Slack", nil, main_monitor,    position.right50,    nil, nil},
        {"Google Chrome", "Calendar", main_monitor, position.left50,    nil, nil},
    }

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end

CommsLayout = function()
    CloseAllWindows()

    local layout = {
        {"Slack", nil, main_monitor,    position.leftThird,    nil, nil},
        {"Slack", nil, main_monitor,    position.leftThird,    nil, nil},
        {"Google Chrome", "Reader", main_monitor,    position.rightThird,    nil, nil},
        {"Google Chrome", "Search", main_monitor,    position.centerThirdFulllength,    nil, nil},
        {"Google Chrome", "Calendar", macbook_monitor,    position.left50,    nil, nil},
        {"Todoist", nil, macbook_monitor,    position.right50,    nil, nil},
    }

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')
    hs.application.launchOrFocus('Todoist')

    -- Open the reader
    hs.urlevent.openURL("https://wordpress.com/read/a8c")


    -- Open mentions gmail search
    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://mail.google.com/mail/u/0/#search/is%3Ainbox+AND++(+%22You+were+mentioned%22+OR+(+from%3A(donotreply%40wordpress.com)+subject%3A(mentioned+you)+)+OR+OR+cc%3Amention%40noreply.github.com+)")

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
        hs.alert("Slack p2 layout applied")
    end)
end

SlackP2 = function()
    CloseAllWindows()

    local layout = {
        {"Slack", nil, main_monitor,    position.centered60Top,    nil, nil},
        {"Google Chrome", "Reader", main_monitor,    position.centered40Bottom,    nil, nil},
    }

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

    -- Open the reader
    hs.urlevent.openURL("https://wordpress.com/read/a8c")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
        hs.alert("Slack p2 layout applied")
    end)
end
--
-- Layout for checking out and closing the day.
--
function closingTheday()
    CloseAllWindows()

    local layout = {
        {"Google Chrome", "Calendar", main_monitor, position.left50,    nil, nil},
        {"Google Chrome", "Outcomes", main_monitor,    position.right50,    nil, nil},
        {"Slack", nil, macbook_monitor,    position.right50,    nil, nil},
    }

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

    -- Ouctomes Journal Notion
    hs.urlevent.openURL("https://www.notion.so/dd0bd03cac0b4cd2803962996024abe4?v=6221b429a53748ec9886f32644b21186")

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")


    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end


--
-- Layout for objective planning
--
function planningLayout()
    CloseAllWindows()

    local layout = {
        {"Google Chrome", "Calendar", main_monitor, position.leftThird,    nil, nil},
        {"Google Chrome", "Objectives", main_monitor, position.centerThirdFulllength,    nil, nil},
        {"Google Chrome", "Outcomes", main_monitor,    position.rightThird,    nil, nil},
        {"Todoist", nil, macbook_monitor,    position.right50,    nil, nil},
    }

    hs.application.launchOrFocus('Google Chrome')
    hs.application.launchOrFocus('Todoist')

    -- Ouctomes Journal Notion
    hs.urlevent.openURL("https://www.notion.so/dd0bd03cac0b4cd2803962996024abe4?v=6221b429a53748ec9886f32644b21186")

    NewWindow("Google Chrome")
    -- Objectives Notion
    hs.urlevent.openURL("https://www.notion.so/cba3bd56b12a423cbd4de60503679f57?v=1266e77586a94b27b7450e2dfe803ff8")

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")


    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end


-- A layout for doing 1on1s.
function OneOnOne()
    CloseAllWindows()

    local layout= {
        -- {"kitty",         nil, macbook_monitor, hs.layout.left50, nil, nil},
        {"Google Chrome", "Google Meet", main_monitor,    position.centerThirdHalfTop,    nil, nil},
        {"Google Chrome", "New Tab", main_monitor,    position.rightThird,    nil, nil},
        {"Slack",         nil, main_monitor,    position.centerThirdHalfBottom,   nil, nil},
    }

  hs.application.launchOrFocus('kitty')
  hs.application.launchOrFocus('Slack')
  hs.application.launchOrFocus('Google Chrome')
  hs.urlevent.openURL("https://meet.google.com/")
  NewWindow("Google Chrome")

  local slack = hs.application.find('slack')
  slack:selectMenuItem({"View", "Hide Sidebar"})

  hs.timer.doAfter(3, function()
      hs.layout.apply(layout, TitleComparitor)
  end)

  -- Todo
  -- One one for each person ( a popup po ask who this session is for )
  -- jump directly to the persons doc and slack channel
end

CloseAllWindows = function ()
    local allWindows = hs.window:allWindows()
    local message = "Closed: \n"
    for index in pairs(allWindows) do
        local window = allWindows[index]

        logger.i( window:application():name())
        logger.i( window:application():name()~="kitty")
        --don't close kitty
        if window:application():name()~="kitty" then
            logger.i('not kitty')
            logger.i(window:application():name())
            message = message .. " " .. window:application():name() .. "\n"
            window:close()
        end
    end
    hs.alert(message, 3)
end

NewWindow = function (appId)
    local app = hs.application.find(appId)
    app:selectMenuItem({"File", "New Window"})
end

TitleComparitor = function (a,b)
    return b==string.match(a, b)
end

LayoutBindings = Init()

local calendar = hs.application.find('calendar')
local refreshCalendar = function()
    hs.eventtap.keyStroke({"cmd"}, "R", 200, calendar)
    hs.alert('Calendar Refreshed', 2)
end
hs.hotkey.bind( hyper,"c",refreshCalendar)

hs.hotkey.bind( hyper,"l",function ()
    local message = "Layout bindings: \n"
    for index, layout in pairs(LayoutBindings) do
        hs.hotkey.bind( hyper,layout[1],layout[2])
        message = message .. layout[1]..". "..layout[3] .. "\n"
    end
    hs.alert(message, 3)
end)

hs.alert.show("Config loaded")

