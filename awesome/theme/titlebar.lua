local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")
local lain  = require("lain")
local dpi   = require("beautiful.xresources").apply_dpi

local mouse = mouse

local separators = lain.util.separators
local arrow = separators.arrow_left

local function titlebar_widgets_factory(args)
    assert(args)

    local widgets = {
        theme = assert(args.theme, 'theme has to be defined'),
        items = {len = 0}
    }

    if args.theme_dir then
        widgets.theme_dir = args.theme_dir 
    end

    -- Adds another widget with a specific color.
    function widgets:add(widget, bg_color, left_margin, right_margin)
        assert(widget, 'A widget has to be provided')

        if not bg_color then
            bg_color = self.theme.bg_normal
        end
        if not left_margin then
            left_margin = dpi(3)
        end
        if not right_margin then
            right_margin = dpi(3)
        end

        self.items.len = self.items.len + 1
        self.items[self.items.len] = {
            widget = widget,
            bg_color = bg_color,
            left_margin = left_margin,
            right_margin = right_margin
        }
    end

    -- build return the right titlebar widget bar.
    function widgets:build()
        local right_bar = wibox.widget{
            layout = wibox.layout.fixed.horizontal,
            wibox.widget.systray(),
        }

        local last_item = nil
        for i = 1, self.items.len, 1 do
            local item = self.items[i]
            local sep = arrow(self.theme.bg_normal, item.bg_color)
            if last_item ~= nil then
                sep = arrow(last_item.bg_color, item.bg_color)
            end

            local w = wibox.container.background(wibox.container.margin(item.widget, item.left_margin, item.right_margin), item.bg_color)
            
            right_bar:add(sep)
            right_bar:add(w)
            last_item = item
        end

        return right_bar
    end

    return widgets
end

return {
    titlebar_widgets = titlebar_widgets_factory
}