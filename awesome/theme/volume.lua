local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local gears = require("gears")
local keygrabber = require("awful.keygrabber")

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

-- args can contain the following properties
-- update_vol: function func(volume_num) that updates the current volume
local function new_volume_slider(args)
    local vol_slider = {}

    if args then
        if args.update_vol then
            vol_slider.update_vol = args.update_vol
        end
    end

    local volume_num = get_volume()
    local default_sink = get_default_sink()

    local function circle_helper(cr)
        return gears.shape.circle(cr, 20, 20)
    end

    local slider = wibox.widget{
        bar_shape           = gears.shape.rounded_rect,
        bar_height          = 3,
        bar_color           = "#6200EE",
        handle_color        = "#6200EE",
        handle_shape        = circle_helper,
        handle_border_color = "#6200EE",
        handle_border_width = 1,
        handle_margins      = 5,
        minimum             = 0,
        maximum             = 100,
        forced_height       = 32,
        forced_width        = 400,
        value               = volume_num,
        widget              = wibox.widget.slider,
    }

    slider:connect_signal("property::value", function (s, v)
        local res = os.execute("pamixer --set-volume " .. tostring(slider.value))
        if res == false then
            naughty.notify({ text = "Unable to set sink volume " .. tostring(res), screen = mouse.screen })
            return
        end

        vol_slider.update_vol(slider.value)
    end)
    

    vol_slider.popup = awful.popup{
        widget = {
            {
                layout = wibox.layout.align.vertical,
                {
                    text = default_sink.displyName,
                    widget = wibox.widget.textbox
                },
                slider,
            },
            margins = 20,
            widget  = wibox.container.margin
        },
        maximum_width = 400,
        maximum_height = 200,
        preferred_positions = 'bottom',
        preferred_anchors = 'middle',
        ontop = true,
    }
    vol_slider.popup:move_next_to(mouse.current_widget_geometry)
    vol_slider.popup.visible = true

    local grabber = function (_, key, event)
        if event ~= "press" then return end

        if key == "Escape" then
            vol_slider:hide()
        end
    end

    function vol_slider:is_visible()
        return self.popup.visible        
    end

    function vol_slider:hide()
        keygrabber.stop(self._keygrabber)
        self.popup.visible = false
    end

    function vol_slider._keygrabber(...)
        grabber(...)
    end

    keygrabber.run(vol_slider._keygrabber)

    return vol_slider
end

function factory(theme_dir)

    local volume_widget = {}

    volume_widget.theme_dir = theme_dir
    local text =  wibox.widget.textbox()
    text:set_align("right")

    local icon = wibox.widget.imagebox(theme_dir .. "/icons/volume_up.svg")
    volume_widget.widget = wibox.widget { icon, text, layout = wibox.layout.align.horizontal }
    local defaultSinkTooltip = awful.tooltip{ objects = {volume_widget.widget}, text = "N/A" }
    volume_widget.widget:connect_signal("mouse::enter", function ()
        local defaultSink = get_default_sink()
        defaultSinkTooltip.text = defaultSink.displyName
    end)

    local volume_slider = nil
    local dmenu = nil

    function volume_widget.detail()
        local items = {}
        local sinks = get_sinks()

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

        dmenu = awful.menu({items = items, theme = { width = 350, height = 20 }})
        dmenu:show()
    end

    function volume_widget.display_volume_slider()
        local volume_num = get_volume()


        local function circle_helper(cr)
            return gears.shape.circle(cr, 20, 20)
        end

        local slider = wibox.widget{
            bar_shape           = gears.shape.rounded_rect,
            bar_height          = 3,
            bar_color           = "#6200EE",
            handle_color        = "#6200EE",
            handle_shape        = circle_helper,
            handle_border_color = "#6200EE",
            handle_border_width = 1,
            handle_margins      = 5,
            minimum             = 0,
            maximum             = 100,
            forced_height       = 32,
            forced_width        = 400,
            value               = volume_num,
            widget              = wibox.widget.slider,
        }

        slider:connect_signal("property::value", function (s, v)
            local res = os.execute("pamixer --set-volume " .. tostring(slider.value))
            if res == false then
                naughty.notify({ text = "Unable to set sink volume " .. tostring(res), screen = mouse.screen })
                return
            end
            text:set_markup(" ".. tostring(slider.value) .. "%")
        end)

        volume_slider = awful.popup{
            widget = {
                slider,
                margins = 20,
                widget  = wibox.container.margin
            },
            maximum_width = 400,
            maximum_height = 200,
            preferred_positions = 'bottom',
            preferred_anchors = 'middle',
            ontop = true,
        }
        volume_slider:move_next_to(mouse.current_widget_geometry)
        volume_slider.visible = true
    end

    volume_widget.widget:buttons(awful.util.table.join(
        awful.button({}, 1, function ()
            if dmenu == nil or not dmenu.wibox.visible then
                volume_widget.detail()
            else
                dmenu:hide()
                dmenu = nil
            end
        end),
        awful.button({}, 3, function ()
            if volume_slider == nil or not volume_slider:is_visible() then
                volume_slider = new_volume_slider({
                    update_vol = function (val)
                        text:set_markup(" ".. tostring(val) .. "%")
                    end
                })
            else
                volume_slider:hide()
                volume_slider = nil
            end
        end)
    ))

    function volume_widget.update()
        local count = get_volume()
        local mute = get_mute()
    
        local volume = " ".. tostring(count) .. "%"
        local icon_img = volume_widget.theme_dir .. icon_vol_up
        if mute == "true" or count == 0  then
            icon_img = volume_widget.theme_dir .. icon_vol_mute
            volume = " M " ..volume
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