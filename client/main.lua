--[[
    Client: buyer NPCs, blips, target and the sale panel.
]]

local peds = {}
local current = nil -- buyer index while the panel is open

local function handle(result)
    result = result or { ok = false, msg = 'err_generic' }
    if result.msg then Notify(L(result.msg, table.unpack(result.args or {})), result.ok and 'success' or 'error') end
    return result
end

local function open(index)
    if current then return end
    local result = handle(lib.callback.await('jvl_sales:open', false, index))
    if not result.ok then return end
    current = index
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open', data = result.data, image = Config.ImagePath,
        logo = Config.LogoUrl or '', icon = Config.Icon or 'fa-solid fa-recycle',
        version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0),
        texts = {
            title = L('ui_title'), have = L('ui_have'), each = L('ui_each'), total = L('ui_total'), sell = L('ui_sell'),
            all = L('ui_all'), none = L('ui_none'), close = L('ui_close'), cash = L('ui_cash'), bank = L('ui_bank'),
        },
    })
end

RegisterNUICallback('close', function(_, cb)
    current = nil
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

RegisterNUICallback('sell', function(data, cb)
    if not current then return cb({ ok = false }) end
    local result = handle(lib.callback.await('jvl_sales:sell', false, current, data.cart))
    if result.ok then
        -- Refresh what is left in the inventory
        local fresh = lib.callback.await('jvl_sales:open', false, current)
        if fresh and fresh.ok then SendNUIMessage({ action = 'update', data = fresh.data }) end
    end
    cb(result)
end)

CreateThread(function()
    local target = Config.Target
    if target == 'auto' then
        target = GetResourceState('ox_target') == 'started' and 'ox_target' or GetResourceState('qb-target') == 'started' and 'qb-target' or nil
    end

    for index, buyer in ipairs(Config.Buyers) do
        local c = buyer.ped.coords
        local hash = joaat(buyer.ped.model)
        if pcall(lib.requestModel, hash, 10000) then
            local ped = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w, false, true)
            SetModelAsNoLongerNeeded(hash)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
            if buyer.ped.scenario then TaskStartScenarioInPlace(ped, buyer.ped.scenario, 0, true) end
            peds[#peds + 1] = ped
            local onSelect = function() open(index) end
            if target == 'ox_target' then
                exports.ox_target:addLocalEntity(ped, { { name = 'jvl_sales:' .. index, label = L('target_sell'), icon = 'fa-solid fa-dollar-sign', distance = Config.TargetDistance, onSelect = onSelect } })
            elseif target == 'qb-target' then
                exports['qb-target']:AddTargetEntity(ped, { options = { { label = L('target_sell'), icon = 'fa-solid fa-dollar-sign', action = onSelect } }, distance = Config.TargetDistance })
            end
        end

        if buyer.blip then
            local blip = AddBlipForCoord(c.x, c.y, c.z)
            SetBlipSprite(blip, buyer.blip.sprite or 365)
            SetBlipColour(blip, buyer.blip.colour or 2)
            SetBlipScale(blip, buyer.blip.scale or 0.8)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(buyer.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    if current then SetNuiFocus(false, false) end
end)
