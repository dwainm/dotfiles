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

-- TODOs
-- 1. Open a new tab in chrome function that takes a url to open.
-- 2. A has tab function that scans chrome for a tab. 

-- Screens
secondary_monitor = "Built-in Retina Display"
main_monitor = hs.screen.primaryScreen()
if "secondary_monitor" == main_monitor:name() then
    secondary_monitor = nil
end


-- Logging

-- Configuring layouts
-- API works in percentages 0.333 = 33.3%
local position = {
    maximized = hs.layout.maximized,
    -- Centered
    centered                 = {x=0.15, y=0.15, w=0.7, h=0.7},
    centeredFullHeight       = {x=0.15, y=0, w=0.7, h=1},
    centered60Top            = {x=0.15, y=0, w=0.7, h=0.6},
    centered55Top            = {x=0.15, y=0, w=0.7, h=0.55},
    centered45Bottom         = {x=0.15, y=0.55, w=0.7, h=0.45},
    centered40Bottom         = {x=0.15, y=0.6, w=0.7, h=0.4},
    centerThirdHalfTop       = {x=0.333, y=0, w=0.333, h=0.5},
    centerThirdHalfBottom    = {x=0.333, y=0.5, w=0.333, h=0.5},
    centerThirdFulllength    = {x=0.333, y=0, w=0.333, h=1},
    offCenterLeftThirdFullLength = {x=0.15, y=0, w=0.333, h=1},
    right52 = {x=0.48, y=0, w=0.52, h=1},
    fullScreen = {x=0, y=0, w=1, h=1},

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
        {"6" , FocusGeneral, "Focus General"},
        {"7" , CodeWrangling, "Code Wrangling"},
        {"8" , CommsLayout, "Commms"},
        {"9" , closingTheday, "Closing The day"},
    }

    for index, layout in pairs(layoutBindings) do
        hs.hotkey.bind( hyper,layout[1],layout[2])
    end
    return layoutBindings
end

SprintManagement = function ()

    closeAppWindowsButKeepAppOpen('Google Chrome')
	-- closeAllOtherApps

    local layout = {
        {"Slack", nil, main_monitor,    position.centered60Top,    nil, nil},
        {"Google Chrome", "Sprints", secondary_monitor, position.right50,    nil, nil},
        {"Google Chrome", "#sprint", main_monitor, position.right50,    nil, nil},
        {"Google Chrome", "Sigma Planner", main_monitor, position.left50,    nil, nil},
    }

	closeAppWindowsButKeepAppOpen("Google Chrome")

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

	-- Team Planner:
    hs.urlevent.openURL("https://docs.google.com/spreadsheets/d/1_ruX4wG0p30tzXKZcRmQ4g32SYeNMUz3hfKEg2g9M-4/edit#gid=0")
	-- Sprint Board:
    hs.urlevent.openURL("https://github.com/orgs/Automattic/projects/553/views/2")
	-- Sprint report:
    hs.urlevent.openURL("https://github.com/orgs/Automattic/projects/553/insights/3")
	-- Open the sprint weekly report generator as well:
    hs.urlevent.openURL("https://docs.google.com/spreadsheets/d/1_ruX4wG0p30tzXKZcRmQ4g32SYeNMUz3hfKEg2g9M-4/edit#gid=545550972")
    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://howdysigma.wordpress.com/tag/sprint/")
    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://howdysigma.wordpress.com/sprints/#weekly-responsibilities")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end

CalendarSlack = function ()
    local layout = {
        {"Slack", nil, main_monitor,    position.right50,    nil, nil},
        {"Google Chrome", "Calendar", main_monitor, position.left50,    nil, nil},
    }

	closeAppWindowsButKeepAppOpen("Google Chrome")

    hs.application.launchOrFocus('Slack')
    hs.application.launchOrFocus('Google Chrome')

    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")

    -- todo sent slack commands to jump to channel
    -- slack = hs.application.find('slack')
    -- hs.eventtap.keyStroke({"cmd"}, "R", 200, slack)
    -- hs.eventtap.keyStroke({"cmd"}, "R", 200, slack)

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end

CommsLayout = function()
    closeAppWindowsButKeepAppOpen('Google Chrome')

    local layout = {
        {"Slack", nil, main_monitor,    position.leftThird,    nil, nil},
        {"Slack", nil, main_monitor,    position.leftThird,    nil, nil},
        {"Google Chrome", "Reader", main_monitor,    position.rightThird,    nil, nil},
        {"Google Chrome", "Search", main_monitor,    position.centerThirdFulllength,    nil, nil},
        {"Google Chrome", "Calendar", secondary_monitor,    position.left50,    nil, nil},
        {"Todoist", nil, secondary_monitor,    position.right50,    nil, nil},
    }
	closeAppWindowsButKeepAppOpen("Google Chrome")

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
    local layout = {
        {"Slack", nil, main_monitor,    position.centered60Top,    nil, nil},
        {"Google Chrome", "Reader", main_monitor,    position.centered40Bottom,    nil, nil},
    }
	closeAppWindowsButKeepAppOpen("Google Chrome")

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
    local layout = {
        {"Google Chrome", "Calendar", main_monitor, position.left50,    nil, nil},
        {"Google Chrome", "Outcomes", main_monitor,    position.right50,    nil, nil},
        {"Slack", nil, secondary_monitor,    position.right50,    nil, nil},
    }

    closeAppWindowsButKeepAppOpen('Google Chrome')

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
-- Layout for Focus Not Code
--
function FocusGeneral()
    local layout = {
        {"Google Chrome", "Google", main_monitor, position.centeredFullHeight,nil, nil},
        {"Slack", nil, secondary_monitor, position.left50,    nil, nil},
        {"Google Chrome", "Calendar", secondary_monitor, position.right50,    nil, nil},
    }

	closeAppWindowsButKeepAppOpen("Google Chrome")
    hs.application.launchOrFocus('Google Chrome')

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://www.google.com")

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://calendar.google.com/calendar/u/0/r/custom/5/d")

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end


--
-- Layout for objective planning
--
function CodeWrangling()
    local layout = {
        {"kitty", nil, main_monitor, position.offCenterLeftThirdFullLength,    nil, nil},
        {"Slack", nil, secondary_monitor, position.left50,    nil, nil},
        {"Google Chrome", "Google", main_monitor, position.right52,    nil, nil},
        {"Google Chrome", "Issues", secondary_monitor, position.right50,    nil, nil},
    }

	closeAppWindowsButKeepAppOpen("Google Chrome")
    hs.application.launchOrFocus('Google Chrome')

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://www.google.com")

    NewWindow("Google Chrome")
    hs.urlevent.openURL("https://github.com/issues/assigned")

    hs.application.launchOrFocus('kitty')

    hs.timer.doAfter(3, function()
        hs.layout.apply(layout, TitleComparitor)
    end)
end


--
-- Layout for objective planning
--
function planningLayout()
    local layout = {
        {"Google Chrome", "Calendar", main_monitor, position.leftThird,    nil, nil},
        {"Google Chrome", "Objectives", main_monitor, position.centerThirdFulllength,    nil, nil},
        {"Google Chrome", "Outcomes", main_monitor,    position.rightThird,    nil, nil},
        {"Todoist", nil, secondary_monitor,    position.right50,    nil, nil},
    }

	closeAppWindowsButKeepAppOpen("Google Chrome")

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
    local layout= {
        -- {"kitty",         nil, secondary_monitor, hs.layout.left50, nil, nil},
        {"Google Chrome", "Google Meet", main_monitor,    position.centerThirdHalfTop,    nil, nil},
        {"Google Chrome", "New Tab", main_monitor,    position.rightThird,    nil, nil},
        {"Slack",         nil, main_monitor,    position.centerThirdHalfBottom,   nil, nil},
    }

  closeAppWindowsButKeepAppOpen("Google Chrome")

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

closeAllOtherApps = function (layouts)
	-- Todo
	-- Loop through layouts and all windows to create a list of windows to close
	-- only close the other windows
    local allWindows = hs.window:allWindows()
    local message = "Closed: \n"
    for index in pairs(allWindows) do
        local window = allWindows[index]

        -- check to see if the layouts to ignore are in the list of allWindows
        -- and avoid closing them, this saves time.
        --don't close kitty
        if not forceAll and (window:application():name()=="kitty" or window:application():name()=="Google Chrome") then
			-- Do nothing
		else
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

closeAppWindowsButKeepAppOpen = function (appId)
    local app = hs.application.find(appId)
	local appWindows = app:allWindows()
    for index in pairs(appWindows) do
        local window = appWindows[index]
		window:application():selectMenuItem({"File", "Close Window"})
	end
end

TitleComparitor = function (title,matcher)
	-- look for the matcher inside the title
	local start = string.find(title,matcher)
	return start ~= nil

end

LayoutBindings = Init()

local refreshCalendar = function()
    hs.eventtap.keyStroke({"cmd"}, "R", 200, hs.application.find('calendar'))
    hs.alert('Calendar Refreshed', 2)
end
hs.hotkey.bind( hyper,"c",refreshCalendar)

-- Show layouts
-- local ctrlCmdOpt = { 'ctrl', 'cmd', 'alt' }
-- hs.hotkey.bind(ctrlCmdOpt, "t", function()
--   local lastApplication = hs.application.frontmostApplication()
--   hs.application.get("Hammerspoon"):activate()
--   hs.dialog.textPrompt("Test prompt", "Enter something", "", "OK", "Cancel")
--   if lastApplication then
--     lastApplication:activate()
--   end
-- end)
hs.hotkey.bind( hyper,"l",function ()
    local message = "Layout bindings: \n"
    for index, layout in pairs(LayoutBindings) do
        hs.hotkey.bind( hyper,layout[1],layout[2])
        message = message .. layout[1]..". "..layout[3] .. "\n"
    end
    hs.alert(message, 3)
end)

hs.alert.show("Config loaded")

