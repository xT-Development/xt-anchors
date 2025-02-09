local config = lib.load('config')
local operating = false

local GetEntityModel = GetEntityModel
local IsThisModelABoat = IsThisModelABoat
local NetworkGetNetworkIdFromEntity = NetworkGetNetworkIdFromEntity

local function toggleAnchor()
    if operating or not cache.vehicle or cache.seat ~= -1 then return end
    if not IsThisModelABoat(GetEntityModel(cache.vehicle)) then return end

    local ent = Entity(cache.vehicle)
    local state = ent.state
    if state then
        local netId = NetworkGetNetworkIdFromEntity(cache.vehicle)

        operating = true
        config.playSound(cache.vehicle)
        if lib.progressCircle({
            duration = (config.timeToLowerAndRaiseAnchor * 1000),
            position = 'bottom',
            label = 'Operating the Boat Anchor...',
            useWhileDead = false,
            canCancel = false,
            disable = { car = true },
        }) then
            operating = false
            TriggerServerEvent('xt-anchors:toggleAnchor', not state.boat_anchor, netId)
        end
    end
end

local DoesEntityExist = DoesEntityExist
local DisableControlAction = DisableControlAction

local function disableControlsIfAnchorDeployed()
    if not IsThisModelABoat(GetEntityModel(cache.vehicle)) then return end

    local state = Entity(cache.vehicle).state
    CreateThread(function()
        local sleep = 0
        while cache.vehicle and cache.seat == -1 do
            if state.boat_anchor then
                sleep = 0
                DisableControlAction(0, 71, true) -- W
                DisableControlAction(0, 72, true) -- S
            else
                sleep = 500
            end
            Wait(sleep)
        end
    end)
end

local SetBoatAnchor = SetBoatAnchor
local SetVehicleEngineOn = SetVehicleEngineOn
local CanAnchorBoatHere_2 = CanAnchorBoatHere_2
local IsBoatAnchoredAndFrozen = IsBoatAnchoredAndFrozen
local SetBoatFrozenWhenAnchored = SetBoatFrozenWhenAnchored
local GetIsVehicleEngineRunning = GetIsVehicleEngineRunning
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId

AddStateBagChangeHandler('boat_anchor', nil, function(bagName, _, value)
    local entity = tonumber(bagName:match('entity:(%d+)'))
    local vehicle = NetworkGetEntityFromNetworkId(entity)
    if not vehicle then return end
    if not DoesEntityExist(vehicle) then return end

    if not value then
        if not IsBoatAnchoredAndFrozen(vehicle) then return end

        SetBoatAnchor(vehicle, false)
        SetBoatFrozenWhenAnchored(vehicle, false)
    else
        if not CanAnchorBoatHere_2(vehicle) then return end

        if config.killEngineWhenLowered then
            if GetIsVehicleEngineRunning(vehicle) then
                SetVehicleEngineOn(vehicle, false, false, true)
            end
        end

        SetBoatAnchor(vehicle, true)
        SetBoatFrozenWhenAnchored(vehicle, true)
    end
end)

lib.onCache('seat', function(newseat)
    if not newseat or newseat ~= -1 then return end

    disableControlsIfAnchorDeployed()
end)

local anchorKey
anchorKey = lib.addKeybind({
    name = 'boat_anchor',
    description = 'Toggle Boat Anchor',
    defaultKey = config.anchorKey,
    onReleased = function(self)
        toggleAnchor()

        anchorKey:disable(true)
        Wait(1000)
        anchorKey:disable(false)
    end
})

exports('toggleAnchor', toggleAnchor)