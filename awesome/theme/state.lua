
local os = require("os")
local lfs = require("lfs")

local stateDir = os.getenv("HOME") .. "/.config/awesome-state"

local function new_state()
    local state = {}

    lfs.mkdir(stateDir)

    function state:get(key)
        local file = io.open(stateDir .. "/" .. key)
        if file == nil then
            return nil
        end
        local data = file:read()
        file:close()
        return data
    end

    function state:set(key, value)
        local file = io.open(stateDir .. "/" .. key, "w")
        file:write(value)
        file:close()
    end

    return state
end

return new_state()