local config = lib.require('config')

local playersUsingTasers = {}

-- update player taser info and metadata
local function updatePlayerTaser(src, remainingCartridges)
    if not playersUsingTasers[src] then
        return
    end

    playersUsingTasers[src] = {
        slot = playersUsingTasers[src].slot,
        cartridges = remainingCartridges
    }

    local slotInfo = exports.ox_inventory:GetSlot(src, playersUsingTasers[src].slot)
    local metadata = slotInfo and slotInfo.metadata or {}
    metadata.cartridges = remainingCartridges
    exports.ox_inventory:SetMetadata(src, playersUsingTasers[src].slot, metadata)

    return true, remainingCartridges
end

-- reload taser with cartridges in inventory
lib.callback.register('xt-taser:server:reloadTaser', function(src)
    if not playersUsingTasers[src] then
        return
    end

    local cartridgeCount = exports.ox_inventory:GetItemCount(src, config.taserCartridgeItem)
    if cartridgeCount > config.maxCartridges then
        cartridgeCount = config.maxCartridges
    end

    if exports.ox_inventory:RemoveItem(src, config.taserCartridgeItem, cartridgeCount) then
        return updatePlayerTaser(src, cartridgeCount)
    end

    return false
end)

-- player shoots taser, reduce remaining cartridges metadata
RegisterNetEvent('xt-taser:server:shootTaser', function()
    local src = source
    if not playersUsingTasers[src] then
        return
    end

    local remainingCartridges = playersUsingTasers[src].cartridges - 1
    updatePlayerTaser(src, remainingCartridges)
end)

-- player used stun gun item, assign remaining cartridges
AddEventHandler('ox_inventory:usedItem', function(playerId, name, slotId, metadata)
    if name ~= 'WEAPON_STUNGUN' then
        if name:find('WEAPON') and playersUsingTasers[playerId] then -- reset player using taser
            playersUsingTasers[playerId] = nil
        end
        return
    end

    local remainingCartridges

    -- force assign metadata for cartridges when equipping
    if not metadata.cartridges then
        metadata.cartridges = config.maxCartridges
        exports.ox_inventory:SetMetadata(playerId, slotId, metadata)
    end

    -- update remaining cartridges
    remainingCartridges = metadata.cartridges <= config.maxCartridges and metadata.cartridges or config.maxCartridges

    -- assign cartridges to player by slot used (so we can update when shooting)
    -- set remaining cartridges and update
    playersUsingTasers[playerId] = {
        slot = slotId,
        cartridges = remainingCartridges
    }
end)