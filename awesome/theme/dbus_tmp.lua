local ldbus = require "ldbus"
local inspect = require("inspect")


local dbus = {}

function query ( )
	print ( "Calling remote method with " )

	local conn = assert ( ldbus.bus.get ( "system" ) )

	--assert ( ldbus.bus.request_name ( conn , "test.signal.source" , { replace_existing = true } ) )
	
	--local msg = assert ( ldbus.message.new_method_call ( "test.method.server" , "/test/method/Object" , "test.method.Type" , "Method" ) , "Message Null" )
    local msg = assert ( ldbus.message.new_method_call ( "net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects" ), "message nil")
	local iter = ldbus.message.iter.new ( )
	--msg:iter_init_append ( iter )
	
	--assert ( iter:append_basic ( param ) , "Out of Memory" )
	
	local reply = assert ( conn:send_with_reply_and_block ( msg ) )
	assert ( reply:iter_init ( iter ) , "Message has no arguments" )
    print(inspect(ldbus))
    print("Type " .. iter:get_arg_type())
	--assert ( iter:get_arg_type ( ) == ldbus.types.boolean , "Argument not boolean!" )

    local args = dbus.iter_args(iter)
    print(inspect(args))
	--assert ( iter:next ( ) )
	--assert ( iter:get_arg_type ( ) == ldbus.types.uint32 , "Argument not int!" )
	--local level = iter:get_basic ( )
	print( "Got reply: " .. tostring ( args ) )
end

-- iterates over a dbus reponse and returns a lua object
function dbus.iter_args(iter, alltype)
    local args = { len = 0 }
    if not iter then return args end
    typ = alltype or iter:get_arg_type()
    while true do
        if not typ then
            args.len = args.len + 1
            args[args.len] = nil
        elseif typ == ldbus.types.variant then
            local nargs = dbus.iter_args(iter:recurse())
            for i = 1, nargs.len do
                args[args.len + i] = nargs[i]
            end
            args.len = args.len + nargs.len
        elseif typ == ldbus.types.dict_entry then
            local nargs = dbus.iter_args(iter:recurse())
            local kwargs = {}
            for i = 1, nargs.len, 2 do
                kwargs[nargs[i]] = nargs[i + 1]
            end
            args.len = args.len + 1
            args[args.len] = kwargs
        elseif typ == ldbus.types.struct then
            local nargs = dbus.iter_args(iter:recurse())
            args.len = args.len + 1
            args[args.len] = nargs
        elseif typ == ldbus.types.array then
            local nargs = dbus.iter_args(iter:recurse())
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

query()