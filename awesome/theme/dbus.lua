local ldbus = require("ldbus")
local inspect = require("inspect")

local function new_dbus(conn)
    local dbus = {
        conn = conn
    }

    -- Queries a dbus service without arguments
    function dbus:simple_query(service, path, object, method)
        assert(self.conn, "Connection not set")

        local msg = assert ( ldbus.message.new_method_call ( service, path, object, method ), "message nil")
	    local iter = ldbus.message.iter.new ( )
        local reply = assert ( conn:send_with_reply_and_block ( msg ) )
        assert ( reply:iter_init ( iter ) , "Message has no arguments" )
        local args = dbus.iter_args_legacy(iter)
        return args
    end


    -- iterates over a dbus reponse and returns a lua object
    function dbus.iter_args_legacy(iter, alltype)
        local args = { len = 0 }
        if not iter then return args end
        typ = alltype or iter:get_arg_type()
        while true do
            if not typ then
                --args[args.len] = nil
                --args.len = args.len + 1
            elseif typ == ldbus.types.variant then
                local nargs = dbus.iter_args_legacy(iter:recurse())
                for i = 1, nargs.len do
                    if nargs[i] then
                        args.len = args.len + 1
                        args[args.len] = nargs[i]
                    end
                end
            elseif typ == ldbus.types.dict_entry then
                local nargs = dbus.iter_args_legacy(iter:recurse())
                --args.len = nil
                if nargs.len then
                    for i = 1, nargs.len, 2 do
                        args[nargs[i]] = nargs[i + 1]
                        args.len = args.len + 1
                    end
                else
                    for k, v in pairs(nargs) do
                        args[k] = v
                    end
                end
            
            elseif typ == ldbus.types.struct then
                local nargs = dbus.iter_args_legacy(iter:recurse())
                args.len = args.len + 1
                args[args.len] = nargs
            elseif typ == ldbus.types.array then
                local nargs = dbus.iter_args_legacy(iter:recurse())
                args.len = args.len + 1
                args[args.len] = nargs
            elseif dbus.is_basic_type(typ) then
                args.len = args.len + 1
                args[args.len] = iter:get_basic()
            else
                args.len = args.len + 1
                args[args.len] = iter:get_basic()
            end
            if iter:next() then
                typ = alltype or iter:get_arg_type()
            else
                break
            end
        end
        return args
    end

    -- iterates over a dbus reponse and returns a lua object
    function dbus.iter_args(iter)
        local args = { len = 0 }
        if not iter then return nil end
        repeat
            local a = dbus.iter_arg(iter)
            
            args[args.len] = a
            args.len = args.len + 1
            iter:next()
        until not iter:has_next()
        -- while iter:has_next() do
            
        -- end
        if args.len == 1 then
            return args[0]
        end
        return args
    end

    function dbus.iter_arg(iter)
        local typ = iter:get_arg_type()
        if not typ then
            return nil
        elseif typ == ldbus.types.variant then
            local nargs = dbus.iter_args(iter:recurse())
            local args = { len = 0}
            for i = 1, nargs.len do
                args[args.len] = nargs[i]
                args.len = args.len + 1
            end
        elseif typ == ldbus.types.dict_entry then
            local nargs = dbus.iter_args(iter:recurse())
            if type(nargs) == 'string' then
                iter:next()
                local struct = {
                    [nargs] = "test"
                }
                print("iter_arg - de: " .. inspect(nargs))
                print("iter_arg - " .. type(nargs))
                print("iter_arg - next: " .. inspect(dbus.iter_arg(iter)))
                print("iter_arg - " .. inspect(struct))
                return struct
            end
            
            print("iter_arg - next type: ", dbus.get_human_readably_type(iter:get_arg_type()))
            local kwargs = {}
            for i = 1, nargs.len, 2 do
                kwargs[nargs[i]] = nargs[i + 1]
            end
            return kwargs
        elseif typ == ldbus.types.struct then
            local nargs = dbus.iter_args(iter:recurse())
            print("iter_arg - struct: " .. inspect(nargs))
            return nargs
        elseif typ == ldbus.types.array then
            print("iter_arg - arr")
            return dbus.iter_args(iter:recurse())
        elseif dbus.is_basic_type(typ) then
            return iter:get_basic()
        else
            return iter:get_basic()
        end
    end

    function dbus.is_basic_type(typ) 
        for k, v in pairs(ldbus.basic_types) do
            if v == typ then
                return true
            end
        end
        return false
    end

    function dbus.get_human_readably_type(type)
        for k, v in pairs(ldbus.types) do
            if v == type then
                return k
            end
        end
        return ""
    end

    function dbus:set_conn(conn) 
        self.conn = conn
    end

    return dbus
end

return {
    new = new_dbus
}