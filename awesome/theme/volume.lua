local wibox = require("wibox")
local awful = require("awful")

local icon_dir = "/icons/"
local icon_vol_up = icon_dir .. "volume_up.svg"
local icon_vol_down = icon_dir .. "volume_down.svg"
local icon_vol_mute = icon_dir .. "volume_mute.svg"

function factory(theme_dir)

    local volume_widget = {}

    volume_widget.theme_dir = theme_dir
    local text =  wibox.widget.textbox()
    text:set_align("right")

    local icon = wibox.widget.imagebox(theme_dir .. "/icons/volume_up.svg")
    volume_widget.widget = wibox.widget { icon, text, layout = wibox.layout.align.horizontal }

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