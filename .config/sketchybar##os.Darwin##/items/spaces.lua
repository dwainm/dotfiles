local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local sbar = require('sketchybar')

-- Static workspace list
local all_spaces = {'q', 'w', 'f', 'p', 'g'}

local spaces = {}
local space_border_items = {}

-- Helper: parse aerospace window list output into icon string
local function parse_windows_to_icons(workspace_windows)
    local icon_line = ""
    local apps = {}

    for line in workspace_windows:gmatch('[^\n]+') do
        local app_name = line:match('| ([^|]+) |')
        if app_name then
            app_name = app_name:gsub('^%s*(.-)%s*$', '%1') -- trim whitespace
            apps[app_name] = true
        end
    end

    for app, _ in pairs(apps) do
        local lookup = app_icons[app]
        local icon = lookup or app_icons["Default"]
        icon_line = icon_line .. icon
    end

    return icon_line ~= "" and icon_line or " —"
end

-- Helper: update a space's window icons asynchronously
local function update_space_icons(workspace_name)
    local space = spaces[workspace_name]
    if not space then return end

    sbar.exec('aerospace list-windows --workspace ' .. workspace_name, function(result)
        local icon_line = parse_windows_to_icons(result or "")
        space:set({ label = { string = icon_line } })
    end)
end

-- Create space items (with placeholder labels, will be populated async)
for counter, workspace_name in ipairs(all_spaces) do
    local space = sbar.add("item", "space." .. workspace_name, {
        position = 'left',
        padding_left = counter == 1 and 10 or 1,
        padding_right = counter == #all_spaces and 10 or 1,
        icon = {
            font = { family = settings.font.numbers },
            string = workspace_name,
            padding_left = 15,
            padding_right = 8,
            color = colors.white,
            highlight_color = colors.red,
        },
        label = {
            string = " —",  -- placeholder until async load
            padding_right = 20,
            color = colors.grey,
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

-- Subscribe to window changes to update app icons (ASYNC)
space_window_observer:subscribe("aerospace_workspace_change", function(env)
    -- Update bracket border color based on focused workspace
    local has_focused_workspace = false
    for _, workspace_name in ipairs(all_spaces) do
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

    -- Async: Get windows for the focused workspace
    sbar.exec('aerospace list-windows --workspace ' .. env.FOCUSED_WORKSPACE, function(result)
        local icon_line = parse_windows_to_icons(result or "")
        local current_space = spaces[env.FOCUSED_WORKSPACE]
        if current_space then
            sbar.animate("tanh", 10, function()
                current_space:set({ label = icon_line })
            end)
        end
    end)
end)

spaces_indicator:subscribe("swap_menus_and_spaces", function(_)
    local currently_on = spaces_indicator:query().icon.value == icons.switch.on
    spaces_indicator:set({
        icon = currently_on and icons.switch.off or icons.switch.on
    })
end)

spaces_indicator:subscribe("mouse.entered", function(_)
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

spaces_indicator:subscribe("mouse.exited", function(_)
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

spaces_indicator:subscribe("mouse.clicked", function(_)
    sbar.trigger("swap_menus_and_spaces")
end)

-- Initial async load: get focused workspace and update all spaces
sbar.exec('aerospace list-workspaces --focused', function(focused)
    focused = (focused or ""):gsub('%s+', '')

    -- Update focused state for all spaces
    for _, workspace_name in ipairs(all_spaces) do
        local space = spaces[workspace_name]
        local selected = workspace_name == focused
        space:set({
            icon = { color = selected and colors.red or colors.white },
            label = { color = selected and colors.white or colors.grey }
        })
        -- Load window icons for each space
        update_space_icons(workspace_name)
    end

    -- Update bracket
    spaces_bracket:set({
        background = {
            border_color = (focused ~= "") and colors.grey or colors.bg2
        }
    })
end)

return {
    space_border_items = space_border_items,
}
