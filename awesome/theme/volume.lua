local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local mouse = mouse

local icon_dir = "/icons/"
local icon_vol_up = icon_dir .. "volume_up.svg"
local icon_vol_down = icon_dir .. "volume_down.svg"
local icon_vol_mute = icon_dir .. "volume_mute.svg"
local icon_default = icon_dir .. "check_circle.svg"

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

function magiclines(s)
    if s:sub(-1)~="\n" then s=s.."\n" end
    return s:gmatch("(.-)\n")
end

function factory(theme_dir)

    local volume_widget = {}

    volume_widget.theme_dir = theme_dir
    local text =  wibox.widget.textbox()
    text:set_align("right")

    local icon = wibox.widget.imagebox(theme_dir .. "/icons/volume_up.svg")
    volume_widget.widget = wibox.widget { icon, text, layout = wibox.layout.align.horizontal }

    local dmenu = nil

    function volume_widget.detail()
        local items = {}
        local sinks, defaultSink = get_sinks()

        local longestName = 0
        for i, sink in ipairs(sinks) do
            if string.len(sink.displyName) > longestName then
                longestName = string.len(sink.displyName)
            end

            local icon = ""
            if sink.default then
                icon = theme_dir .. icon_default
            end

            table.insert(items, {
                sink.displyName, function () -- onclick
                    local res = os.execute("pacmd set-default-sink " .. tostring(sink.id))
                    if res == false then
                        naughty.notify({ text = "Unable to change default sink " .. tostring(res), screen = mouse.screen })
                        return
                    end
                    naughty.notify({ text = "Set " .. sink.displyName .. " as default sink", screen = mouse.screen })
                    dmenu:hide()
                    dmenu = nil
                end,
                icon
            })
        end

        dmenu = awful.menu({items = items, theme = { width = 350 }})
        dmenu:show()
    end

    volume_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if dmenu == nil then
                volume_widget.detail()
            else
                dmenu:hide()
                dmenu = nil
            end
        end)
    ))

    function volume_widget.update()
        local fd = io.popen("pamixer --get-volume")
        local count = fd:read("*all")
        fd:close()
        count = tonumber(count)
    
        fd = io.popen("pamixer --get-volume")
        local mute = fd:read("*all")
        fd:close()
    
        local volume = " ".. count .. "%"
        local icon_img = volume_widget.theme_dir .. icon_vol_up
        if mute == "true" or count == 0  then
            icon_img = volume_widget.theme_dir .. icon_vol_mute
        elseif count < 50 then
            icon_img = volume_widget.theme_dir .. icon_vol_down
        end
        text:set_markup(volume)
        icon:set_image(icon_img)
    end

    volume_widget.update()
    local mytimer = timer({ timeout = 1 })
    mytimer:connect_signal("timeout", volume_widget.update)
    mytimer:start()

    return volume_widget
end

return factory