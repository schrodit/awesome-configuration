local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local keygrabber = require("awful.keygrabber")

local mouse = mouse

local theme_dir = os.getenv("HOME") .. "/.config/awesome/theme"
local icon_dir = "/icons/"

local icon_menu = icon_dir .. "menu.svg"
local icon_menu_open = icon_dir .. "menu_open.svg"


local icon_poweroff = icon_dir .. "poweroff.svg"
local icon_poweroff_hover = icon_dir .. "poweroff_hover.svg"

local icon_hibernate = icon_dir .. "hibernate.svg"
local icon_hibernate_hover = icon_dir .. "hibernate_hover.svg"

local icon_logout = icon_dir .. "logout.svg"
local icon_restart = icon_dir .. "restart.svg"
local icon_restart_hover = icon_dir .. "restart_hover.svg"

local icon_lock = icon_dir .. "lock.svg"
local icon_lock_hover = icon_dir .. "lock_hover.svg"

local function do_poweroff()
    local res = os.execute("systemctl poweroff")
    if res == false then
        naughty.notify({ text = "Unable to shutdown the system: " .. tostring(res), screen = mouse.screen })
        return false
    end
    return true
end

local function do_hibernate()
    local res = os.execute("systemctl hibernate")
    if res == false then
        naughty.notify({ text = "Unable to hibernate the system: " .. tostring(res), screen = mouse.screen })
        return false
    end
    return true
end

local function do_reboot()
    local res = os.execute("systemctl reboot")
    if res == false then
        naughty.notify({ text = "Unable to reboot the system: " .. tostring(res), screen = mouse.screen })
        return false
    end
    return true
end

local function do_lock()
    local res = os.execute("dm-tool lock")
    if res == false then
        naughty.notify({ text = "Unable to lock the system: " .. tostring(res), screen = mouse.screen })
        return false
    end
    return true
end

-- Creates a new system menu entry with a icon and action that 
-- is executed in click.
--
local function new_system_menu_entry(args)
    local entry = {}

    entry.icon = args.icon
    entry.icon_hover = args.icon
    if args.icon_hover then
        entry.icon_hover = args.icon_hover
    end
    entry.action = args.action
    entry.on_hide = args.on_hide

    entry.icon_widget = wibox.widget.imagebox(entry.icon)
    entry.icon_widget.forced_height = 32
    entry.icon_widget.forced_width = 32

    entry.widget = wibox.widget{
        entry.icon_widget,
        margins = 5,
        widget  = wibox.container.margin
    }

    entry.widget:connect_signal("mouse::enter", function ()
        entry.icon_widget:set_image(entry.icon_hover)
    end)
    entry.widget:connect_signal("mouse::leave", function ()
        entry.icon_widget:set_image(entry.icon)
    end)

    entry.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if entry.on_hide then
                entry.on_hide()
            end
            entry.action()
        end)
    ))

    return entry
end

-- args can contain the following properties
-- update_vol: function func(volume_num) that updates the current volume
local function new_system_menu(args)
    local smenu = {
        theme_dir = theme_dir
    }

    if args then
        if args.theme_dir then
            smenu.theme_dir = args.theme_dir
        end
        smenu.on_hide = args.on_hide
    end

    local function hide_cb()
        smenu:hide()
    end

    smenu.poweroff_entry = new_system_menu_entry({
        icon = args.theme_dir .. icon_poweroff,
        icon_hover = args.theme_dir .. icon_poweroff_hover,
        tooltip = "Poweroff",
        on_hide = hide_cb,
        action = function ()
                do_poweroff()
        end
    })

    smenu.reboot_entry = new_system_menu_entry({
        icon = args.theme_dir .. icon_restart,
        icon_hover = args.theme_dir .. icon_restart_hover,
        tooltip = "Reboot",
        action = function ()
            do_reboot()
        end
    })

    smenu.hibernate_entry = new_system_menu_entry({
        icon = args.theme_dir .. icon_hibernate,
        icon_hover = args.theme_dir .. icon_hibernate_hover,
        tooltip = "Hibernate",
        on_hide = hide_cb,
        action = function ()
            do_hibernate()
        end
    })

    smenu.lock_entry = new_system_menu_entry({
        icon = args.theme_dir .. icon_lock,
        icon_hover = args.theme_dir .. icon_lock_hover,
        tooltip = "Lock",
        on_hide = hide_cb,
        action = function ()
            do_lock()
        end
    })
    

    smenu.popup = awful.popup{
        widget = {
            {
                layout = wibox.layout.flex.vertical,
                smenu.poweroff_entry.widget,
                smenu.reboot_entry.widget,
                smenu.hibernate_entry.widget,
                smenu.lock_entry.widget,
            },
            margins = 10,
            widget  = wibox.container.margin
        },
        maximum_width = 100,
        maximum_height = 10000,
        height = 800,
        preferred_positions = 'bottom',
        preferred_anchors = 'middle',
        ontop = true,
    }

    local grabber = function (_, key, event)
        if event ~= "press" then return end

        if key == "Escape" then
            smenu:hide()
        end
    end

    function smenu:is_visible()
        return self.popup.visible        
    end

    function smenu:hide()
        keygrabber.stop(self._keygrabber)
        self.popup.visible = false
        if smenu.on_hide then
            smenu.on_hide()
        end
    end

    function smenu._keygrabber(...)
        grabber(...)
    end

    keygrabber.run(smenu._keygrabber)

    -- add an offset to the geometry if there is not enough space for the popup.
    -- otherwise the popup would be placed on the left top corner.
    local current_geo = mouse.current_widget_geometry
    local current_screen_geo = mouse.screen.geometry
    local space_left = current_screen_geo.width - current_geo.x
    local widget_geo = current_geo
    if space_left < 40 then
        widget_geo.x = current_screen_geo.width - 45
    end
    
    smenu.popup:move_next_to(widget_geo)
    smenu.popup.visible = true

    return smenu
end

function factory(theme_dir)

    local system_widget = {
        theme_dir = os.getenv("HOME") .. "/.config/awesome/theme"
    }

    if theme_dir then
        system_widget.theme_dir = theme_dir 
    end

    local icon = wibox.widget.imagebox(system_widget.theme_dir .. icon_menu)
    system_widget.widget = icon

    local menu = nil

    system_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if menu == nil or not menu:is_visible() then
                menu = new_system_menu({
                    theme_dir = system_widget.theme_dir,
                    on_hide = function ()
                        icon:set_image(system_widget.theme_dir .. icon_menu)
                    end
                })
                icon:set_image(system_widget.theme_dir .. icon_menu_open)
            else
                menu:hide()
                menu = nil
            end
        end)
    ))

    return system_widget
end

return factory