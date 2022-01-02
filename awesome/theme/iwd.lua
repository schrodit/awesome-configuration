
local ldbus = require("ldbus")
local inspect = require("inspect")

local dbus = require("theme.dbus")

local iwdNetwork = "net.connman.iwd.Network"
local iwdKnownNetwork = "net.connman.iwd.KnownNetwork"
local iwdStation = "net.connman.iwd.Station"

local function new_iwd()
    local iwd = {}

    iwd.conn = assert ( ldbus.bus.get ( "system" ) )

    iwd.dbus = dbus.new(iwd.conn)

    -- Returns all networks and the currently connected as second tuple argument.
    -- The connected network is nil if no network is connected.
    function iwd:get_networks()
        local objects = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")

        local networks, connected_net = self:get_plain_networks(objects)

        local station = self:get_station(objects)
        if not station then
            print("station not found")
            return networks, connected_net
        end

        -- create new ordered networks
        local ordered_networks = {}
        local ordered_nets = self:list_ordered_networks(station)
        for i, v in ipairs(ordered_nets) do
            local net = assert(networks[v.object_path], "network not found")
            net.signal_strength = v.signal_strength
            table.insert(ordered_networks, net)
        end

        return ordered_networks, connected_net
    end

    -- Returns all networks and the currently connected as second tuple argument.
    -- The connected network is nil if no network is connected.
    function iwd:get_plain_networks(objects)
        if not objects then
            objects = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")
        end

        local connected_net = nil
        local networks = {}
        for object, v in pairs(objects[1]) do
            -- ignore the len attribute
            if object ~= 'len' then
                for resource, obj in pairs(v) do
                    if resource == iwdNetwork then
                        local connected = false
                        if obj["Connected"] then
                            connected = obj["Connected"]
                        end
                        local net = {
                            object_path = object,
                            name = obj["Name"],
                            connected = connected,
                            type = obj["Type"],
                        }
                        networks[object] = net

                        if connected then
                            connected_net = net
                        end
                    end
                end
            end
            
        end

        return  networks, connected_net
    end

    function iwd:get_known_networks()
        local args = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")

        local networks = {}
        for k, v in pairs(args[1]) do
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

    function iwd:get_station(objects)
        if not objects then
            objects = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")
        end

        -- parse objects and find the first station
        for k, v in pairs(objects[1]) do
            -- ignore the len attribute
            if k ~= 'len' then
                for resource, obj in pairs(v) do
                    if resource == iwdStation then
                        return k
                    end
                end
            end
        end
        return nil
    end

    function iwd:get_stations(objects)
        if not objects then
            objects = self.dbus:simple_query("net.connman.iwd" , "/" , "org.freedesktop.DBus.ObjectManager" , "GetManagedObjects")
        end

        -- parse objects and find the first station
        local stations = {}
        for k, v in pairs(objects[1]) do
            -- ignore the len attribute
            if k ~= 'len' then
                for resource, obj in pairs(v) do
                    if resource == iwdStation then
                        table.insert(stations, k)
                    end
                end
            end
        end
        return stations
    end

    -- returns a list of iwd ordered networks and their connection strenght
    function iwd:list_ordered_networks(station_obj_id)
        assert(station_obj_id, "station object path is missing")
        local station = self.dbus:simple_query("net.connman.iwd" , station_obj_id , "net.connman.iwd.Station" , "GetOrderedNetworks")

        local nets = {}

        for i, v in ipairs(station[1]) do
            table.insert(nets, {
                object_path = v[1],
                signal_strength = v[2]
            })
        end

        return nets
    end
    
    return iwd
end

return {
    new = new_iwd
}