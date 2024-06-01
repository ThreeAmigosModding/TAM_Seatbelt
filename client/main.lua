---@diagnostic disable: redundant-return-value
--[[------------------------------------------------------
----       For Support - discord.gg/threeamigos       ----
---- Do not edit if you do not know what you"re doing ----
--]]------------------------------------------------------


local seatbeltOn = false
local newVehicleBodyHealth = 0
local currentVehicleBodyHealth = 0
local frameBodyChange = 0
local lastFrameVehiclespeed = 0
local thisFrameVehicleSpeed = 0
local tick = 0
local isDamaged = false
local lastVehicle = nil
local veloc
local config = require "data.config"
local isNotificationSent = false
lib.locale()

local function ejectFromVehicle()
    local coords = GetOffsetFromEntityInWorldCoords(cache.vehicle, 1.0, 0.0, 1.0)
    SetEntityCoords(cache.ped, coords.x, coords.y, coords.z)

    SetPedToRagdoll(cache.ped, 5511, 5511, 0, false, false, false)
    SetEntityVelocity(cache.ped, veloc.x * 4,veloc.y * 4,veloc.z * 4)

    local ejectspeed = math.ceil(GetEntitySpeed(cache.ped) * 8)
    if GetEntityHealth(cache.ped) - ejectspeed > 0 then
        SetEntityHealth(cache.ped, GetEntityHealth(cache.ped) - ejectspeed)
    elseif GetEntityHealth(cache.ped) ~= 0 then
        SetEntityHealth(cache.ped, 0)
    end
end

local function seatbelt()
    local sleep = 1000
    while true do
        if seatbeltOn and cache.vehicle then
            sleep = 0
            lib.disableControls()
            if IsDisabledControlJustPressed(0, 75) and not isNotificationSent then
                lib.notify({description = locale("mustRemoveSeatbeltToExit"), type = "error", duration = 2000})
                isNotificationSent = true
            end
        elseif sleep == 0 then
            sleep = 1000
        end
        Wait(sleep)
    end
end

local function handleVehicleDamaged()
    if isDamaged then return end

    if lastFrameVehiclespeed > 110 and thisFrameVehicleSpeed < (lastFrameVehiclespeed * 0.75) then
        if lib.table.contains(config.blacklistedClasses, GetVehicleClass(cache.vehicle)) then return end

        if not seatbeltOn then
            ejectFromVehicle()
        end
        isDamaged = true
    end
    if currentVehicleBodyHealth < 350.0 then
        isDamaged = true
        Wait(1000)
    end
end

local function handlePedInVehicle()
    SetPedHelmet(cache.ped, false)
    lastVehicle = cache.vehicle
    if GetVehicleEngineHealth(cache.vehicle) < 0.0 then
        SetVehicleEngineHealth(cache.vehicle, 0.0)
    end

    thisFrameVehicleSpeed = GetEntitySpeed(cache.vehicle) * 3.6
    currentVehicleBodyHealth = GetVehicleBodyHealth(cache.vehicle)
    if currentVehicleBodyHealth == 1000 and frameBodyChange ~= 0 then
        frameBodyChange = 0
    end

    if frameBodyChange ~= 0 then
        handleVehicleDamaged()
    end

    if lastFrameVehiclespeed < 100 then
        Wait(100)
        tick = 0
    end

    frameBodyChange = newVehicleBodyHealth - currentVehicleBodyHealth

    if tick > 0 then
        tick -= 1
        if tick == 1 then
            lastFrameVehiclespeed = GetEntitySpeed(cache.vehicle) * 3.6
        end
    else
        if isDamaged then
            isDamaged = false
            frameBodyChange = 0
            lastFrameVehiclespeed = GetEntitySpeed(cache.vehicle) * 3.6
        end
        local currentSpeed = GetEntitySpeed(cache.vehicle) * 3.6
        if currentSpeed > lastFrameVehiclespeed then
            lastFrameVehiclespeed = GetEntitySpeed(cache.vehicle) * 3.6
        end
        if currentSpeed < lastFrameVehiclespeed then
            tick = 25
        end

    end

    if tick < 0 then
        tick = 0
    end

    newVehicleBodyHealth = GetVehicleBodyHealth(cache.vehicle)
    veloc = GetEntityVelocity(cache.vehicle)
end

local function handlePedNotInVehicle()
    if lastVehicle then
        SetPedHelmet(cache.ped, true)
        Wait(200)
        newVehicleBodyHealth = GetVehicleBodyHealth(lastVehicle)
        if not isDamaged and newVehicleBodyHealth < currentVehicleBodyHealth then
            isDamaged = true
            Wait(1000)
        end
        lastVehicle = nil
    end
    lastFrameVehiclespeed = 0
    newVehicleBodyHealth = 0
    currentVehicleBodyHealth = 0
    frameBodyChange = 0
    Wait(2000)
end

local function playSound(entity, sound)
    while not RequestScriptAudioBank("audiodirectory/tam_seatbelt", false) do Wait(0) end

    local soundId = GetSoundId()

    PlaySoundFromEntity(soundId, sound, entity, "tam_seatbelt", true)
    ReleaseSoundId(soundId)
    ReleaseNamedScriptAudioBank("audiodirectory/tam_seatbelt")
end

local function toggleSeatbelt()
    if not cache.vehicle or IsPauseMenuActive() then return end
    local class = GetVehicleClass(cache.vehicle)
    if lib.table.contains(config.blacklistedClasses, class) then return end

    if not seatbeltOn then
        playSound(cache.ped, "buckle")
        lib.disableControls:Add(75)
        seatbeltOn = true
        return
    else
        playSound(cache.ped, "unbuckle")
        lib.disableControls:Remove(75)
        seatbeltOn = false
        return
    end
end

lib.addKeybind({
    name = "toggleSeatbelt",
    description = locale("keybindDescription"),
    defaultKey = config.keyboardBind,
    defaultMapper = "KEYBOARD",
    secondaryKey = config.controllerBind,
    secondaryMapper = "PAD_DIGITALBUTTON",
    onPressed = function(self)
        toggleSeatbelt()
    end
})

lib.onCache("vehicle", function(value)
    seatbelt()
end)

lib.callback.register("tam_seatbelt:checkStatus", function()
    return seatbeltOn
end)

exports("seatbeltActive", function() return seatbeltOn end)

CreateThread(function()
    while true do
        Wait(0)
        if cache.vehicle and cache.vehicle ~= false and cache.vehicle ~= 0 then
            handlePedInVehicle()
        else
            handlePedNotInVehicle()
        end
    end
end)

CreateThread(function()
    local sleep = 500
    while true do
        if cache.vehicle then
            sleep = 250
            SendNUIMessage({
                action = "updateSeatbelt",
                seatbelt = seatbeltOn
            })
            isNotificationSent = false
        else
            SendNUIMessage({
                action = "updateSeatbelt",
                seatbelt = true
            })
            sleep = 500
        end
        Wait(sleep)
    end
end)