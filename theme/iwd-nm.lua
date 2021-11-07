--[[
--]]

local wibox                = require("wibox")
local spawn                = require("awful.spawn")
local gmatch, lines, floor = string.gmatch, io.lines, math.floor

-- Network widget based on iwd
-- It uses iwctl to restrieve network information.

local function factory(args)
    args           = args or {}

    local iwdnm      = { widget = args.widget or wibox.widget.textbox() }
    local timeout  = args.timeout or 2
    local settings = args.settings or function() end

    function iwdnm.update()
        spawn.easy_async('iwctl station list', function(stdout, stderr)
            
        end)

        mem_now = {}
        for line in lines("/proc/meminfo") do
            for k, v in gmatch(line, "([%a]+):[%s]+([%d]+).+") do
                if     k == "MemTotal"     then mem_now.total = floor(v / 1024 + 0.5)
                elseif k == "MemFree"      then mem_now.free  = floor(v / 1024 + 0.5)
                elseif k == "Buffers"      then mem_now.buf   = floor(v / 1024 + 0.5)
                elseif k == "Cached"       then mem_now.cache = floor(v / 1024 + 0.5)
                elseif k == "SwapTotal"    then mem_now.swap  = floor(v / 1024 + 0.5)
                elseif k == "SwapFree"     then mem_now.swapf = floor(v / 1024 + 0.5)
                elseif k == "SReclaimable" then mem_now.srec  = floor(v / 1024 + 0.5)
                end
            end
        end

        mem_now.used = mem_now.total - mem_now.free - mem_now.buf - mem_now.cache - mem_now.srec
        mem_now.swapused = mem_now.swap - mem_now.swapf
        mem_now.perc = math.floor(mem_now.used / mem_now.total * 100)

        widget = iwdnm.widget
        settings()
    end

    helpers.newtimer("iwdnm", timeout, iwdnm.update)

    return iwdnm
end

return factory