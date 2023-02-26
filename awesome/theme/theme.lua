--[[

     Based on Powerarrow Awesome WM theme
     github.com/lcpz

--]]

local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local beautiful     = require("beautiful")
local dpi   = require("beautiful.xresources").apply_dpi

--[[

    Additonal widgets

--]]

local volume_widget = require("theme/volume")
local system_widget = require("theme/system")
local titlebar = require("theme/titlebar")
local net_widget   = require("theme/net")

local math, string, os = math, string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/theme"
theme.wallpaper                                 = theme.dir .. "/dunes.png"
theme.fg_normal                                 = "#FEFEFE"
theme.fg_focus                                  = "#32D6FF"
theme.fg_urgent                                 = "#C83F11"
theme.bg_normal                                 = "#222222"
theme.bg_focus                                  = "#1E2320"
theme.bg_urgent                                 = "#3F3F3F"
theme.taglist_fg_focus                          = "#00CCFF"
theme.tasklist_bg_focus                         = "#222222"
theme.tasklist_fg_focus                         = "#00CCFF"
theme.border_width                              = dpi(2)
theme.border_normal                             = "#3F3F3F"
theme.border_focus                              = "#6F6F6F"
theme.border_marked                             = "#CC9393"
theme.titlebar_bg_focus                         = "#3F3F3F"
theme.titlebar_bg_normal                        = "#3F3F3F"
theme.titlebar_bg_focus                         = theme.bg_focus
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
theme.menu_font                                 = "Roboto " .. dpi(11)
theme.menu_height                               = dpi(17)
theme.menu_width                                = dpi(140)
theme.menu_submenu_icon                         = theme.dir .. "/icons/submenu.png"
theme.awesome_icon                              = theme.dir .. "/icons/awesome.png"
theme.taglist_squares_sel                       = theme.dir .. "/icons/square_sel.png"
theme.taglist_squares_unsel                     = theme.dir .. "/icons/square_unsel.png"
theme.layout_tile                               = theme.dir .. "/icons/tile.png"
theme.layout_tileleft                           = theme.dir .. "/icons/tileleft.png"
theme.layout_tilebottom                         = theme.dir .. "/icons/tilebottom.png"
theme.layout_tiletop                            = theme.dir .. "/icons/tiletop.png"
theme.layout_fairv                              = theme.dir .. "/icons/fairv.png"
theme.layout_fairh                              = theme.dir .. "/icons/fairh.png"
theme.layout_spiral                             = theme.dir .. "/icons/spiral.png"
theme.layout_dwindle                            = theme.dir .. "/icons/dwindle.png"
theme.layout_max                                = theme.dir .. "/icons/max.png"
theme.layout_fullscreen                         = theme.dir .. "/icons/fullscreen.png"
theme.layout_magnifier                          = theme.dir .. "/icons/magnifier.png"
theme.layout_floating                           = theme.dir .. "/icons/floating.png"
theme.widget_ac                                 = theme.dir .. "/icons/ac.png"
theme.widget_battery                            = theme.dir .. "/icons/battery.png"
theme.widget_battery_low                        = theme.dir .. "/icons/battery_low.png"
theme.widget_battery_empty                      = theme.dir .. "/icons/battery_empty.png"
theme.widget_brightness                         = theme.dir .. "/icons/brightness.png"
theme.widget_mem                                = theme.dir .. "/icons/mem.png"
theme.widget_cpu                                = theme.dir .. "/icons/cpu.png"
theme.widget_temp                               = theme.dir .. "/icons/temp.png"
theme.widget_net                                = theme.dir .. "/icons/net.png"
theme.widget_hdd                                = theme.dir .. "/icons/hdd.png"
theme.widget_music                              = theme.dir .. "/icons/note.png"
theme.widget_music_on                           = theme.dir .. "/icons/note_on.png"
theme.widget_music_pause                        = theme.dir .. "/icons/pause.png"
theme.widget_music_stop                         = theme.dir .. "/icons/stop.png"
theme.widget_vol                                = theme.dir .. "/icons/volume_up.svg"
theme.widget_vol_low                            = theme.dir .. "/icons/vol_low.png"
theme.widget_vol_no                             = theme.dir .. "/icons/vol_no.png"
theme.widget_vol_mute                           = theme.dir .. "/icons/vol_mute.png"
theme.widget_mail                               = theme.dir .. "/icons/mail.png"
theme.widget_mail_on                            = theme.dir .. "/icons/mail_on.png"
theme.widget_task                               = theme.dir .. "/icons/task.png"
theme.widget_scissors                           = theme.dir .. "/icons/scissors.png"
theme.tasklist_plain_task_name                  = true
theme.tasklist_disable_icon                     = true
theme.useless_gap                               = 0

theme.titlebar_ontop_button_focus_active        = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active       = theme.dir .. "/icons/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive      = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive     = theme.dir .. "/icons/titlebar/ontop_normal_inactive.png"
theme.titlebar_sticky_button_focus_active       = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active      = theme.dir .. "/icons/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive     = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive    = theme.dir .. "/icons/titlebar/sticky_normal_inactive.png"
theme.titlebar_floating_button_focus_active     = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active    = theme.dir .. "/icons/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive   = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive  = theme.dir .. "/icons/titlebar/floating_normal_inactive.png"

theme.titlebar_close_button_focus               = theme.dir .. "/icons/sweet-assets/close.svg"
theme.titlebar_close_button_focus_hover         = theme.dir .. "/icons/sweet-assets/close_prelight.svg"
theme.titlebar_close_button_normal              = theme.dir .. "/icons/sweet-assets/close.svg"

theme.titlebar_maximized_button_focus_active         = theme.dir .. "/icons/sweet-assets/maximize.svg"
theme.titlebar_maximized_button_focus_active_hover   = theme.dir .. "/icons/sweet-assets/maximize_prelight.svg"
theme.titlebar_maximized_button_normal_active        = theme.dir .. "/icons/sweet-assets/maximize.svg"
theme.titlebar_maximized_button_normal_active_hover  = theme.dir .. "/icons/sweet-assets/maximize_prelight.svg"

theme.titlebar_maximized_button_focus_inactive        = theme.dir .. "/icons/sweet-assets/maximize_unfocused.svg"
theme.titlebar_maximized_button_focus_inactive_hover  = theme.dir .. "/icons/sweet-assets/maximize_prelight.svg"
theme.titlebar_maximized_button_normal_inactive       = theme.dir .. "/icons/sweet-assets/maximize_unfocused.svg"
theme.titlebar_maximized_button_normal_inactive_hover = theme.dir .. "/icons/sweet-assets/maximize_prelight.svg"

theme.titlebar_minimize_button_normal           = theme.dir .. "/icons/sweet-assets/min.svg"
theme.titlebar_minimize_button_normal_hover     = theme.dir .. "/icons/sweet-assets/min_prelight.svg"
theme.titlebar_minimize_button_normal_press     = theme.dir .. "/icons/sweet-assets/min_pressed.svg"
theme.titlebar_minimize_button_focus            = theme.dir .. "/icons/sweet-assets/min.svg"
theme.titlebar_minimize_button_focus_hover      = theme.dir .. "/icons/sweet-assets/min_prelight.svg"
theme.titlebar_minimize_button_focus_press      = theme.dir .. "/icons/sweet-assets/min_pressed.svg"


local markup = lain.util.markup
local separators = lain.util.separators


-- Separators
local arrow = separators.arrow_left

function theme.at_screen_connect(s)

    theme.border_width                              = dpi(2, s)
    theme.menu_font                                 = "Roboto " .. dpi(11)
    theme.menu_height                               = dpi(17)
    theme.menu_width                                = dpi(140)

    local font_size = 10
    if s.geometry.width == 2560 then
        font_size = tostring(dpi(10, s))
    end
    theme.font = "Roboto " .. font_size
    --local beautiful.font = "Roboto " .. tostring(dpi(8, s))

    -- Taskwarrior
    local task = wibox.widget.imagebox(theme.widget_task)
    lain.widget.contrib.task.attach(task, {
        -- do not colorize output
        show_cmd = "task | sed -r 's/\\x1B\\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g'"
    })
    task:buttons(my_table.join(awful.button({}, 1, lain.widget.contrib.task.prompt)))

    -- Scissors (xsel copy and paste)
    local scissors = wibox.widget.imagebox(theme.widget_scissors)
    scissors:buttons(my_table.join(awful.button({}, 1, function() awful.spawn.with_shell("xsel | xsel -i -b") end)))

    -- MEM
    local memicon = wibox.widget.imagebox(theme.widget_mem)
    local mem = lain.widget.mem({
        settings = function()
            widget:set_markup(markup.font(theme.font, " " .. mem_now.used .. "MB "))
        end
    })

    -- CPU
    local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
    local cpu = lain.widget.cpu({
        settings = function()
            widget:set_markup(markup.font(theme.font, " " .. cpu_now.usage .. "% "))
        end
    })


    -- Battery
    local baticon = wibox.widget.imagebox(theme.widget_battery)
    local bat = lain.widget.bat({
        settings = function()
            if bat_now.status and bat_now.status ~= "N/A" then
                if bat_now.ac_status == 1 then
                    widget:set_markup(markup.font(theme.font, " AC " .. bat_now.perc .. "% "))
                    baticon:set_image(theme.widget_ac)
                    return
                elseif not bat_now.perc and tonumber(bat_now.perc) <= 5 then
                    baticon:set_image(theme.widget_battery_empty)
                elseif not bat_now.perc and tonumber(bat_now.perc) <= 15 then
                    baticon:set_image(theme.widget_battery_low)
                else
                    baticon:set_image(theme.widget_battery)
                end
                widget:set_markup(markup.font(theme.font, " " .. bat_now.perc .. "% "))
            elseif bat_now.status and bat_now.status == "N/A" then
                widget:set_markup(markup.font(theme.font, ""))
                baticon:set_image(theme.widget_ac)
            else
                widget:set_markup(markup.font(theme.font, bat_now.status))
                baticon:set_image(theme.widget_ac)
            end
        end
    })

    -- Coretemp (lain, average)
    local temp = lain.widget.temp({
        settings = function()
            widget:set_markup(markup.font(theme.font, " " .. coretemp_now .. "°C "))
        end
    })
    --]]
    local tempicon = wibox.widget.imagebox(theme.widget_temp)

    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
        wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- Tags
    awful.tag(awful.util.tagnames, s, awful.layout.layouts)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({}, 1, function () awful.layout.inc( 1) end),
                           awful.button({}, 2, function () awful.layout.set( awful.layout.layouts[1] ) end),
                           awful.button({}, 3, function () awful.layout.inc(-1) end),
                           awful.button({}, 4, function () awful.layout.inc( 1) end),
                           awful.button({}, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Create a tasklist widget
    --s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

    -- Placeholder widget
    s.middle_placeholder = wibox.widget{
        text = "",
        widget = wibox.widget.textbox
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = dpi(20, s), bg = theme.bg_normal, fg = theme.fg_normal })

    s.titlebar_widgets = titlebar.titlebar_widgets({theme = theme})
    s.titlebar_widgets:add(wibox.widget { memicon, mem.widget, layout = wibox.layout.align.horizontal }, "#777E76", dpi(2, s))
    s.titlebar_widgets:add(wibox.widget { cpuicon, cpu.widget, layout = wibox.layout.align.horizontal }, "#4B696D", dpi(3, s), dpi(4, s))
    s.titlebar_widgets:add(wibox.widget { tempicon, temp.widget, layout = wibox.layout.align.horizontal }, "#4B3B51", dpi(4, s), dpi(4, s))
    s.titlebar_widgets:add(volume_widget(theme.dir).widget, "#d4ab4c", dpi(4, s), dpi(7, s))
    s.titlebar_widgets:add(net_widget(theme.dir).widget, "#8DAA9A", dpi(4), dpi(7))
    s.titlebar_widgets:add(wibox.widget { baticon, bat.widget, layout = wibox.layout.align.horizontal }, "#CB755B")
    s.titlebar_widgets:add(wibox.widget.textclock(), "#777E76", dpi(4, s), dpi(8, s))
    s.titlebar_widgets:add(system_widget().widget, "alpha", dpi(4, s), dpi(8, s))

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            s.mypromptbox,
            spr,
        },
        s.middle_placeholder,
        s.titlebar_widgets:build(),
    }
end

return theme
