local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local sbar = require('sketchybar')

-- Get aerospace workspace information
local focused_space = io.popen('aerospace list-workspaces --focused'):read('*a'):gsub('%s+', '')
-- Static workspace list
local all_spaces = {'q', 'w', 'f', 'p', 'g'}

local spaces = {}
local space_border_items = {}

-- Create spaces for each aerospace workspace
for counter, workspace_name in pairs(all_spaces) do
    local is_focused = workspace_name == focused_space
    
    -- Get initial windows for this workspace
    local workspace_windows = io.popen('aerospace list-windows --workspace ' .. workspace_name):read('*a')
    local initial_icon_line = ""
    local apps = {}
    
    -- Parse window list to extract app names
    for line in workspace_windows:gmatch('[^\n]+') do
        local app_name = line:match('| ([^|]+) |')
        if app_name then
            app_name = app_name:gsub('^%s*(.-)%s*$', '%1') -- trim whitespace
            apps[app_name] = (apps[app_name] or 0) + 1
        end
    end
    
    -- Build initial icon line from apps
    for app, count in pairs(apps) do
        local lookup = app_icons[app]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        initial_icon_line = initial_icon_line .. icon
    end
    
    if initial_icon_line == "" then
        initial_icon_line = " —"
    end
    
    local space = sbar.add("item", "space." .. workspace_name, {
        position = 'left',
        padding_left = counter == 1 and 10 or 1,
        padding_right = counter == #all_spaces and 10 or 1,
        icon = {
            font = { family = settings.font.numbers },
            string = workspace_name,
            padding_left = 15,
            padding_right = 8,
            color = is_focused and colors.red or colors.white,
            highlight_color = colors.red,
        },
        label = {
            string = initial_icon_line,
            padding_right = 20,
            color = is_focused and colors.white or colors.grey,
            highlight_color = colors.white,
            font = "sketchybar-app-font:Regular:16.0",
            y_offset = -1,
        },
        background = {
            color = colors.bg1,
            border_width = 0,
            height = 26,
        },
        popup = { background = { border_width = 5, border_color = colors.black } }
    })

    spaces[workspace_name] = space
    table.insert(space_border_items, space.name)

    -- Padding space
    sbar.add("item", "space.padding." .. workspace_name, {
        position = 'left',
        width = settings.group_paddings or 5,
    })

    local space_popup = sbar.add("item", {
        position = "popup." .. space.name,
        padding_left = 5,
        padding_right = 0,
        background = {
            drawing = true,
            image = {
                corner_radius = 9,
                scale = 0.2
            }
        }
    })

    -- Subscribe to aerospace workspace changes
    space:subscribe('aerospace_workspace_change', function(env)
        local selected = env.FOCUSED_WORKSPACE == workspace_name
        space:set({
            icon = { 
                highlight = selected,
                color = selected and colors.red or colors.white
            },
            label = { 
                highlight = selected,
                color = selected and colors.white or colors.grey
            }
        })
    end)

    -- Handle mouse clicks to switch workspaces
    space:subscribe('mouse.clicked', function(env)
        if env.BUTTON == "other" then
            space_popup:set({ background = { image = "space." .. workspace_name } })
            space:set({ popup = { drawing = "toggle" } })
        else
            sbar.exec('aerospace workspace ' .. workspace_name)
        end
    end)

    space:subscribe("mouse.exited", function(_)
        space:set({ popup = { drawing = false } })
    end)
end

-- Create single bracket for all spaces
local spaces_bracket = sbar.add("bracket", space_border_items, {
    background = {
        color = colors.transparent,
        border_color = colors.bg2,
        height = 28,
        border_width = 2
    }
})

-- Window observer to show app icons in workspaces
local space_window_observer = sbar.add("item", {
    drawing = false,
    updates = true,
})

-- Spaces indicator
local spaces_indicator = sbar.add("item", {
    padding_left = -3,
    padding_right = 0,
    icon = {
        padding_left = 8,
        padding_right = 9,
        color = colors.grey,
        string = icons.switch.on,
    },
    label = {
        width = 0,
        padding_left = 0,
        padding_right = 8,
        string = "Spaces",
        color = colors.bg1,
    },
    background = {
        color = colors.with_alpha(colors.grey, 0.0),
        border_color = colors.with_alpha(colors.bg1, 0.0),
    }
})

-- Subscribe to window changes to update app icons
space_window_observer:subscribe("aerospace_workspace_change", function(env)
    -- Update bracket border color based on focused workspace
    local has_focused_workspace = false
    for _, workspace_name in pairs(all_spaces) do
        if workspace_name == env.FOCUSED_WORKSPACE then
            has_focused_workspace = true
            break
        end
    end
    
    spaces_bracket:set({
        background = {
            border_color = has_focused_workspace and colors.grey or colors.bg2
        }
    })
    
    -- Get windows for the focused workspace
    local workspace_windows = io.popen('aerospace list-windows --workspace ' .. env.FOCUSED_WORKSPACE):read('*a')
    local icon_line = ""
    local no_app = true
    local apps = {}
    
    -- Parse window list to extract app names
    for line in workspace_windows:gmatch('[^\n]+') do
        local app_name = line:match('| ([^|]+) |')
        if app_name then
            app_name = app_name:gsub('^%s*(.-)%s*$', '%1') -- trim whitespace
            apps[app_name] = (apps[app_name] or 0) + 1
            no_app = false
        end
    end
    
    -- Build icon line from apps
    for app, count in pairs(apps) do
        local lookup = app_icons[app]
        local icon = ((lookup == nil) and app_icons["Default"] or lookup)
        icon_line = icon_line .. icon
    end

    if no_app then
        icon_line = " —"
    end
    
    local current_space = spaces[env.FOCUSED_WORKSPACE]
    if current_space then
        sbar.animate("tanh", 10, function()
            current_space:set({ label = icon_line })
        end)
    end
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(env)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 1.0 },
                border_color = { alpha = 1.0 },
            },
            icon = { color = colors.bg1 },
            label = { width = "dynamic" }
        })
    end)
end)

spaces_indicator:subscribe("mouse.exited", function(env)
    sbar.animate("tanh", 30, function()
        spaces_indicator:set({
            background = {
                color = { alpha = 0.0 },
                border_color = { alpha = 0.0 },
            },
            icon = { color = colors.grey },
            label = { width = 0, }
        })
    end)
end)

spaces_indicator:subscribe("mouse.clicked", function(env)
    sbar.trigger("swap_menus_and_spaces")
end)

return {
    space_border_items = space_border_items,
}