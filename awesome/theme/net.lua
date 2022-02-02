local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local keygrabber = require("awful.keygrabber")
local beautiful = require("beautiful")
local lfs = require("lfs")
local inspect = require("inspect")

local iwd = require("theme/iwd")

local mouse = mouse

local theme_dir = os.getenv("HOME") .. "/.config/awesome/theme"
local icon_dir = "/icons/"
local icon_wifi          = icon_dir .. "wifi.svg"
local icon_wifi_off      = icon_dir .. "wifi_off.svg"
local icon_ethernet      = icon_dir .. "ethernet.svg"

local icon_wifi_password = icon_dir .. "wifi_password.svg"
local icon_wifi_lock     = icon_dir .. "lock.svg"
local icon_wifi_done     = icon_dir .. "done.svg"


local icon_wifi_strength_1 = icon_dir .. "wifi_strenght_1.svg"
local icon_wifi_strength_2 = icon_dir .. "wifi_strenght_2.svg"
local icon_wifi_strength_3 = icon_dir .. "wifi_strenght_3.svg"
local icon_wifi_strength_4 = icon_dir .. "wifi_strenght_4.svg"


local linux_net_class_dir = '/sys/class/net'


local function placeholder_widget(height, width)
    if not width then
        width = height
    end
    local placeholder = wibox.widget{
        text = "",
        widget = wibox.widget.textbox,
    }
    placeholder.forced_height = height
    placeholder.forced_width = width
    return placeholder
end

-- Checks if a wifi device exists by reading "/sys/class/net"
local function wifi_device_exists()
    for dir in lfs.dir(linux_net_class_dir) do
        if dir:find('^wl') then
           return true
        end
    end
    return false
end

local function ethernet_dvc_is_connected(device)
    local carrier_file = io.open(linux_net_class_dir .. '/' .. device .. '/carrier')
    if carrier_file == nil then
        return false
    end
    local carrier = carrier_file:read()
    carrier_file:close();
    return tonumber(carrier) == 1
end

-- Checks if a ethernet device exists and is connected by reading "/sys/class/net"
local function ethernet_connected()
    for device in lfs.dir(linux_net_class_dir) do
        if device:find('^en') then
            if ethernet_dvc_is_connected(device) then
                return true
            end
        end
    end
    return false
end



-- Creates a new wifi endpoint entry with icons and action that 
-- is executed in click.
local function new_wifi_menu_entry(args)
    local entry = {}

    entry.network = assert(args.network, "network needed")
    entry.action = args.action
    entry.on_hide = args.on_hide

    entry.widget_entry = wibox.widget{
        layout = wibox.layout.fixed.horizontal,
        spacing = 5,
    }

    entry.text_widget = wibox.widget{
        markup = entry.network.name,
        widget = wibox.widget.textbox,
    }
    entry.text_background = wibox.container.background(entry.text_widget)

    if entry.network.connected then
        local icon = wibox.widget.imagebox(theme_dir .. icon_wifi_done)
        icon.forced_height = 18
        icon.forced_width = 18
        entry.widget_entry:add(icon)
    else
        entry.widget_entry:add(placeholder_widget(18))
    end

    local strenght_icon = nil
    if entry.network.signal_strength > -5000 then
        strenght_icon = wibox.widget.imagebox(theme_dir .. icon_wifi_strength_4)
    elseif entry.network.signal_strength > -7000 then
        strenght_icon = wibox.widget.imagebox(theme_dir .. icon_wifi_strength_3)
    elseif entry.network.signal_strength > -8000 then
        strenght_icon = wibox.widget.imagebox(theme_dir .. icon_wifi_strength_2)
    else
        strenght_icon = wibox.widget.imagebox(theme_dir .. icon_wifi_strength_1)
    end
    strenght_icon.forced_height = 18
    strenght_icon.forced_width = 18
    entry.widget_entry:add(strenght_icon)


    if entry.network.type == "psk" then
        local icon = wibox.widget.imagebox(theme_dir .. icon_wifi_lock)
        icon.forced_height = 18
        icon.forced_width = 18
        entry.widget_entry:add(icon)
    else
        entry.widget_entry:add(placeholder_widget(18))
    end

    entry.widget_entry:add(entry.text_background)

    entry.widget = wibox.widget{
        entry.widget_entry,
        margins = 5,
        widget  = wibox.container.margin
    }

    entry.widget:connect_signal("mouse::enter", function ()
        entry.text_background:set_fg(beautiful.fg_focus)
        --entry.icon_widget:set_image(entry.icon_hover)
    end)
    entry.widget:connect_signal("mouse::leave", function ()
        entry.text_background:set_fg(beautiful.fg)
        --entry.icon_widget:set_image(entry.icon)
    end)

    entry.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if entry.on_hide then
                entry.on_hide()
            end
            if entry.action then
                entry.action()
            end
        end)
    ))

    return entry
end

-- args can contain the following properties:
-- theme_dir: path to the theme (optional)
-- on_hide: callback that will be called when the menu will be hidden.
local function new_wifi_menu(args)
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

    local items = wibox.widget{
        layout = wibox.layout.flex.vertical
    }
    for i, net in ipairs(args.wifi_widget.networks) do
        
        local icon = ""
        if net.type == "psk" then
            icon = theme_dir .. icon_wifi_password
        end

        items:add(new_wifi_menu_entry({
            network = net,
            on_hide = hide_cb,
            action = function ()
                naughty.notify({ text = "Switch WiFi to " .. net.name .. ". Not implemented yet!", screen = mouse.screen })
                smenu:hide()
            end
        }).widget)
    end
    

    smenu.popup = awful.popup{
        widget = {
            items,
            margins = 10,
            widget  = wibox.container.margin
        },
        maximum_width = 400,
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

local function factory(theme_dir)

    local net_widget = {}

    net_widget.iwd = iwd.new()

    net_widget.theme_dir = theme_dir
    local text =  wibox.widget.textbox()
    text:set_align("right")

    local icon = wibox.widget.imagebox(theme_dir .. icon_wifi)
    net_widget.widget = wibox.widget { icon, text, layout = wibox.layout.align.horizontal }

    if ethernet_connected() then
        icon:set_image(theme_dir .. icon_ethernet)
        return net_widget
    end

    if not wifi_device_exists() then
        icon:set_image(theme_dir .. icon_wifi_off)
        return net_widget
    end

    local connectedNetworkTooltip = awful.tooltip{ objects = {net_widget.widget}, text = "N/A" }
    net_widget.widget:connect_signal("mouse::enter", function ()
        net_widget:update()

        if not net_widget.connected then
            connectedNetworkTooltip.text = "Not connected"
            return
        end

        connectedNetworkTooltip.text = net_widget.connected.name
    end)

    local menu = nil

    net_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if menu == nil or not menu:is_visible() then
                menu = new_wifi_menu({
                    wifi_widget = net_widget,
                    theme_dir = theme_dir,
                })
            else
                menu:hide()
                menu = nil
            end
        end)
    ))

    function net_widget:update()
        net_widget.networks, net_widget.connected = net_widget.iwd:get_networks()

        local icon_img = net_widget.theme_dir .. icon_wifi_off
        if net_widget.connected then
            icon_img = net_widget.theme_dir .. icon_wifi
        end
    
        icon:set_image(icon_img)
    end

    net_widget:update()
    local mytimer = timer({ timeout = 60 })
    mytimer:connect_signal("timeout", function ()
        net_widget:update()
    end)
    mytimer:start()

    return net_widget
end

return factory