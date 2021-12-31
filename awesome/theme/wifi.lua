local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local keygrabber = require("awful.keygrabber")

local iwd = require("theme/iwd")

local mouse = mouse

local icon_dir = "/icons/"
local icon_wifi          = icon_dir .. "wifi.svg"
local icon_wifi_off      = icon_dir .. "wifi_off.svg"
local icon_wifi_password = icon_dir .. "wifi_password.svg"


local function get_default_sink()
    local fd = io.popen("pamixer --get-default-sink")

    local line = fd:read() -- read the first "Default Sink:" line
    line = fd:read() -- read the first real line which should contain the default sink
    fd:close()
    if line == nil then
        return nil
    end

    local sink = {}

    -- read id
    sink.raw = line
    local res = line
    local s, e = res:find(" ")
    sink.id = tonumber(string.sub(res, 1, s))
    res = string.sub(res, s + 1)
    -- read name
    s, e = res:find(" ")
    sink.name = string.sub(res, 2, s-2)
    -- read display name
    sink.displyName = string.sub(res, s+1):sub(2, -2)

    return sink
end

-- Returns a list of all available sinks.
local function get_sinks() 
    local sinks = {}

    local defaultSink = get_default_sink()


    local fd = io.popen("pamixer --list-sinks")

    local line = fd:read() -- read the first "Sink:" line
    line = fd:read() -- read the first real line
    while( line ~= nil ) do
        local sink = {}
        sink.default = false

        -- read id
        sink.raw = line
        local res = line
        local s, e = res:find(" ")
        sink.id = tonumber(string.sub(res, 1, s))
        res = string.sub(res, s + 1)
        -- read name
        s, e = res:find(" ")
        sink.name = string.sub(res, 2, s-2)
        -- read display name
        sink.displyName = string.sub(res, s+1):sub(2, -2)

        if defaultSink ~= nil and sink.name == defaultSink.name then
            sink.default = true
        end

        table.insert(sinks, sink)
        line = fd:read()
    end
    fd:close()

    return sinks, defaultSink
end

-- returns the current volume
local function get_volume()
    local fd = io.popen("pamixer --get-volume")
    local count = fd:read("*all")
    fd:close()
    count = tonumber(count)
    return count
end

-- Returns if the volume is currently muted
local function get_mute()
    local fd = io.popen("pamixer --get-mute")
    local mute = fd:read()
    fd:close()
    return mute
end

local function factory(theme_dir)

    local wifi_widget = {}

    wifi_widget.iwd = iwd.new()

    wifi_widget.theme_dir = theme_dir
    local text =  wibox.widget.textbox()
    text:set_align("right")

    local icon = wibox.widget.imagebox(theme_dir .. "/icons/volume_up.svg")
    wifi_widget.widget = wibox.widget { icon, text, layout = wibox.layout.align.horizontal }
    local connectedNetworkTooltip = awful.tooltip{ objects = {wifi_widget.widget}, text = "N/A" }
    wifi_widget.widget:connect_signal("mouse::enter", function ()
        wifi_widget:update()

        if not wifi_widget.connected then
            connectedNetworkTooltip.text = "Not connected"
            return
        end

        connectedNetworkTooltip.text = wifi_widget.connected.name
    end)

    local dmenu = nil

    function wifi_widget.detail()
        wifi_widget.networks, wifi_widget.connected = wifi_widget.iwd:get_networks()


        local items = {}

        for name, net in pairs(wifi_widget.networks) do
            
            local icon = ""
            if net.type == "psk" then
                icon = theme_dir .. icon_wifi_password
            end

            table.insert(items, {
                name, function () -- onclick
                    naughty.notify({ text = "Switch WiFi to " .. name .. ". Not implemented yet!", screen = mouse.screen })
                    dmenu:hide()
                    dmenu = nil
                end,
                icon
            })
        end

        dmenu = awful.menu({items = items, theme = { width = 200, height = 20 }})
        dmenu:show()
    end

    wifi_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if dmenu == nil or not dmenu.wibox.visible then
                naughty.notify({text = "show"})
                wifi_widget.detail()
            else
                dmenu:hide()
                dmenu = nil
            end
        end)
    ))

    function wifi_widget:update()
        wifi_widget.networks, wifi_widget.connected = wifi_widget.iwd:get_networks()

        local icon_img = wifi_widget.theme_dir .. icon_wifi_off
        if wifi_widget.connected then
            icon_img = wifi_widget.theme_dir .. icon_wifi
        end
    
        icon:set_image(icon_img)
    end

    wifi_widget:update()
    local mytimer = timer({ timeout = 60 })
    mytimer:connect_signal("timeout", function ()
        wifi_widget:update()
    end)
    mytimer:start()

    return wifi_widget
end

return factory