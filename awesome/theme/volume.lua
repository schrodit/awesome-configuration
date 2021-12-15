local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local mouse = mouse

local icon_dir = "/icons/"
local icon_vol_up = icon_dir .. "volume_up.svg"
local icon_vol_down = icon_dir .. "volume_down.svg"
local icon_vol_mute = icon_dir .. "volume_mute.svg"

-- Returns a list of all available sinks.
local function get_sinks() 
    local sinks = {}

    local fd = io.popen("pamixer --get-default-sink")
    local defaultSinkRaw = fd:read("*all")
    fd:close()

    for line in magiclines(defaultSinkRaw) do
        if line ~= "Default sink:" then
            local i = 0
            local sink = {}
            for token in string.gmatch(line, "[^%s]+") do
                
                if i == 0 then sink.id = token
                elseif i == 1 then sink.name = token
                elseif i == 2 then sink.displyName = token
                end

                i = i + 1
            end

            sinks[num_sinks] = sink
            num_sinks = num_sinks + 1
        end
    end


    fd = io.popen("pamixer --list-sinks")
    local raw = fd:read("*all")
    fd:close()

    local num_sinks = 0
    for line in magiclines(raw) do
        if line ~= "Sinks:" then
            local i = 0
            local sink = {}
            for token in string.gmatch(line, "[^%s]+") do
                
                if i == 0 then sink.id = token
                elseif i == 1 then sink.name = token
                elseif i == 2 then sink.displyName = token
                end

                i = i + 1
            end

            sinks[num_sinks] = sink
            num_sinks = num_sinks + 1
        end
    end

    return sinks
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
        naughty.notify({ text = "test", screen = mouse.screen })
    end

    volume_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, volume_widget.detail)
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