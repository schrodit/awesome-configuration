
local ldbus = require("ldbus")
--local inspect = require("inspect")

local dbus = require("theme.dbus")

local iwdNetwork = "net.connman.iwd.Network"
local iwdKnownNetwork = "net.connman.iwd.KnownNetwork"

local function new_iwd()
    local iwd = {}

    iwd.conn = assert ( ldbus.bus.get ( "system" ) )

    iwd.dbus = dbus.new(iwd.conn)

    -- Returns all networks and the currently connected as second tuple argument.
    -- The connected network is nil if no network is connected.
    function iwd:get_networks()
        local args = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")

        local connected_net = nil
        local networks = {}
        for k, v in pairs(args[0]) do
            -- ignore the len attribute
            if k ~= 'len' then
                for resource, obj in pairs(v) do
                    if resource == iwdNetwork then
                        local connected = false
                        if obj["Connected"] then
                            connected = obj["Connected"]
                        end
                        net = {
                            name = obj["Name"],
                            connected = connected,
                            type = obj["Type"],
                        }
                        networks[obj["Name"]] = net

                        if connected then
                            connected_net = net
                        end
                    end
                end
            end
            
        end

        return networks, connected_net
    end

    function iwd:get_known_networks()
        local args = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")

        local networks = {}
        for k, v in pairs(args[0]) do
            -- ignore the len attribute
            if k ~= 'len' then
                for resource, obj in pairs(v) do
                    if resource == iwdKnownNetwork then
                        local connected = false
                        if obj["Connected"] then
                            connected = obj["Connected"]
                        end
                        networks[obj["Name"]] = {
                            name = obj["Name"],
                            connected = connected,
                            type = obj["Type"],
                            auto_connect = obj["AutoConnect"],
                            last_connected = obj["LastConnectedTime"],
                        }
                    end
                end
            end
            
        end

        return networks
    end
    
    return iwd
end

return {
    new = new_iwd
}