local config = lib.require('config')

local taserInfo = {}
local showReloadUI = false
local reloading = false

-- listen for reload input and show UI
local function waitForReloadInput()
    if not showReloadUI then
        showReloadUI = true
        lib.showTextUI('[R] - Reload Taser Cartridges')
    end

    CreateThread(function()
        while (taserInfo and taserInfo.remainingCartridges <= 0) and cache.weapon == `WEAPON_STUNGUN` do
            if IsControlJustReleased(0, 45) and not reloading then
                local hasCartridges = exports.ox_inventory:GetItemCount(config.taserCartridgeItem) > 0
                if not hasCartridges then
                    lib.notify({
                        title = 'No Cartridges',
                        type = 'error'
                    })
                else
                    reloading = true

                    if lib.progressCircle({
                        label = 'Reloading Taser...',
                        duration = config.reloadLength * 1000,
                        position = 'bottom',
                        useWhileDead = false,
                        canCancel = true,
                        disable = { car = true },
                        anim = {
                            dict = 'anim@weapons@pistol@flare_str',
                            clip = 'reload_aim'
                        },
                    }) then
                        local reload = lib.callback.await('xt-taser:server:reloadTaser', false)
                        if reload then
                            lib.notify({
                                title = 'Taser Reloaded',
                                type = 'success'
                            })
                        end
                    else
                        lib.notify({
                            title = 'Cancelled Taser Reload',
                            type = 'error'
                        })
                    end

                    reloading = false
                end
            end

            Wait(10)
        end

        showReloadUI = false
        lib.hideTextUI()
        DisablePlayerFiring(cache.playerId, false)
    end)
end

-- listen for shooting only from the client player
AddEventHandler('CEventGunShot', function(_, shooter, args)
    local pedIsShooter = (shooter == cache.ped)
    if not pedIsShooter then return end

    local weaponIsStunGun = (cache.weapon == `WEAPON_STUNGUN`)
    if not weaponIsStunGun then return end

    TriggerServerEvent('xt-taser:server:shootTaser') -- this will update metadata, which triggers the event below, updating the client
end)

-- listen for current weapon and update stun gun
AddEventHandler('ox_inventory:currentWeapon', function(weapon)
    local isStunGun = weapon and (weapon.name == 'WEAPON_STUNGUN') or false
    if not isStunGun and taserInfo then
        taserInfo = nil

        SendNUIMessage({ action = 'taser:toggle', state = false })
        return
    end

    local remainingCartridges = weapon.metadata?.cartridges or config.maxCartridges

    -- update cached taser info
    taserInfo = {
        slot = weapon.slot,
        remainingCartridges = remainingCartridges
    }

    -- update UI
    SendNUIMessage({ action = 'taser:toggle', state = true })
    SendNUIMessage({ action = 'taser:update', count = remainingCartridges })

    -- wait for weapon to cache
    while cache.weapon ~= `WEAPON_STUNGUN` do
        Wait(0)
    end

    -- start listening for reload and disable firing
    if remainingCartridges <= 0 then
        CreateThread(function()
            waitForReloadInput()

            while (taserInfo and taserInfo.remainingCartridges <= 0) and cache.weapon == `WEAPON_STUNGUN` do
                DisablePlayerFiring(cache.playerId, true)
                Wait(0)
            end
        end)
    end
end)

-- ui handler to set max cartridges on load
RegisterNUICallback('taser:setMax', function(_, cb)
    cb({ max = config.maxCartridges })
end)