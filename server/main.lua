--[[------------------------------------------------------
----       For Support - discord.gg/threeamigos       ----
---- Do not edit if you do not know what you"re doing ----
--]]------------------------------------------------------

local config = require "data.config"
lib.locale()

lib.addCommand(config.checkSeatbeltCommand, {
    help = locale("checkSeatbeltCommandHelp"),
    restricted = false
}, function(source, args, raw)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local veh = lib.getClosestVehicle(coords, 5)
    local ped = GetPedInVehicleSeat(veh, -1)
    local targetId = NetworkGetNetworkIdFromEntity(ped)

    if veh == nil then TriggerClientEvent("ox_lib:notify", source, {title = locale("noVehicleNearby"), type = "error"}) return end

    local status = lib.callback.await("tam_seatbelt:checkStatus", targetId)

    if status == nil then return end
    
    if status then
        TriggerClientEvent("ox_lib:notify", source, {
            title = locale("notificationTitle"),
            description = locale("yesSeatbeltNotification"),
            type = "success"
        })
    else
        TriggerClientEvent("ox_lib:notify", source, {
            title = locale("notificationTitle"),
            description = locale("noSeatbeltNotification"),
            type = "error"
        })
    end
end)