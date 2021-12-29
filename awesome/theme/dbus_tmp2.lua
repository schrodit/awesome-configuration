local ldbus = require "ldbus"
local inspect = require("inspect")

local dbus = require("theme.dbus")
local iwd = require("theme.iwd")


function query ( )
	print ( "Calling remote method with " )

	-- local conn = assert ( ldbus.bus.get ( "system" ) )

    -- local b = dbus.new(conn)
    -- print(inspect(b))
    -- local args = b:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")

    -- print(inspect(args))

    local i = iwd.new()
    print("Networks" .. inspect(i:get_networks()))
    print("Known Networks" .. inspect(i:get_known_networks()))
end

query()