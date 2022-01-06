
local function command_exists(cmd)
    assert(cmd, 'command is required')
    local res = os.execute('command -v ' .. cmd)
    return res
end

return {
    command_exists = command_exists
}
