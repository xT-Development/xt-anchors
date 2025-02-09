local GetVehicleType = GetVehicleType
local GetEntityType = GetEntityType
local DoesEntityExist = DoesEntityExist
local NetworkGetEntityFromNetworkId = NetworkGetEntityFromNetworkId

local function boolToStr(bool)
    return bool and 'Lowered' or 'Raised'
end

RegisterNetEvent('xt-anchors:toggleAnchor', function(setState, netId)
    local src = source
    local entity = NetworkGetEntityFromNetworkId(netId)
    if not entity or not DoesEntityExist(entity) then return end

    local isVeh = GetEntityType(entity) == 2
    if not isVeh then return end
    local isBoat = GetVehicleType(entity) == 'boat'
    if not isBoat then return end

    local ent = Entity(entity)
    if not ent.state then return end

    ent.state:set('boat_anchor', setState, true)

    lib.notify(src, {
        title = ('Anchor %s'):format(boolToStr(setState))
    })
end)