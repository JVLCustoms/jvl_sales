--[[
    Server: what each player can sell and the sale. Prices always come from the config.
]]

local framework = JvlSales.Framework
local QBCore, ESX
if framework == 'qb' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif framework == 'esx' then
    ESX = exports.es_extended:getSharedObject()
end

local lastSale = {}

local function getPlayer(source)
    if framework == 'qbox' then return exports.qbx_core:GetPlayer(source) end
    if framework == 'qb' then return QBCore.Functions.GetPlayer(source) end
    if framework == 'esx' then return ESX.GetPlayerFromId(source) end
end

local function usingOx()
    return GetResourceState('ox_inventory') == 'started'
end

local function countItem(source, item)
    if usingOx() then return exports.ox_inventory:Search(source, 'count', item) or 0 end
    local player = getPlayer(source)
    if not player then return 0 end
    if framework == 'esx' then
        local entry = player.getInventoryItem(item)
        return entry and entry.count or 0
    end
    local entry = player.Functions.GetItemByName(item)
    return entry and entry.amount or 0
end

local function removeItem(source, item, amount)
    if usingOx() then return exports.ox_inventory:RemoveItem(source, item, amount) == true end
    local player = getPlayer(source)
    if not player then return false end
    if framework == 'esx' then player.removeInventoryItem(item, amount) return true end
    return player.Functions.RemoveItem(item, amount) ~= false
end

local function addMoney(source, amount)
    local player = getPlayer(source)
    if not player then return false end
    if framework == 'esx' then
        if Config.PayAccount == 'bank' then player.addAccountMoney('bank', amount, 'jvl_sales') else player.addMoney(amount, 'jvl_sales') end
        return true
    end
    return player.Functions.AddMoney(Config.PayAccount, amount, 'jvl_sales') ~= false
end

local function itemLabel(item)
    if usingOx() then
        local data = exports.ox_inventory:Items(item)
        if data then return data.label end
    elseif framework == 'esx' then
        return ESX.GetItemLabel(item) or item
    elseif QBCore or framework == 'qbox' then
        local items = (QBCore or exports['qb-core']:GetCoreObject()).Shared.Items
        if items[item] then return items[item].label end
    end
    return item
end

local function nearBuyer(source, index)
    local buyer = Config.Buyers[index]
    local ped = GetPlayerPed(source)
    if not buyer or ped == 0 then return false end
    local c = buyer.ped.coords
    return #(GetEntityCoords(ped) - vector3(c.x, c.y, c.z)) <= Config.ServerDistance
end

--- Items this buyer takes, with what the player has of each.
lib.callback.register('jvl_sales:open', function(source, index)
    index = tonumber(index)
    if not nearBuyer(source, index) then return { ok = false, msg = 'err_too_far' } end
    local prices, list = JvlSales.PriceList(index), {}
    for _, entry in ipairs(Config.Items) do
        if prices[entry.item] then
            list[#list + 1] = { item = entry.item, label = entry.label or itemLabel(entry.item), price = entry.price, have = countItem(source, entry.item) }
        end
    end
    return { ok = true, data = { label = Config.Buyers[index].label, items = list, account = Config.PayAccount } }
end)

--- cart = { [item] = amount }
lib.callback.register('jvl_sales:sell', function(source, index, cart)
    index = tonumber(index)
    local now = GetGameTimer()
    if lastSale[source] and now - lastSale[source] < 1000 then return { ok = false, msg = 'err_busy' } end
    lastSale[source] = now
    if not nearBuyer(source, index) then return { ok = false, msg = 'err_too_far' } end
    if type(cart) ~= 'table' then return { ok = false, msg = 'err_nothing' } end
    if not getPlayer(source) then return { ok = false, msg = 'err_generic' } end -- never take items we cannot pay for

    local prices = JvlSales.PriceList(index)
    local total, units = 0, 0
    for item, amount in pairs(cart) do
        amount = math.floor(tonumber(amount) or 0)
        local entry = prices[item]
        if entry and amount > 0 then
            amount = math.min(amount, Config.MaxPerSale, countItem(source, item))
            -- Take the items first; pay only what was really removed
            if amount > 0 and removeItem(source, item, amount) then
                total = total + amount * entry.price
                units = units + amount
            end
        end
    end
    if units == 0 then return { ok = false, msg = 'err_nothing' } end
    addMoney(source, total)
    if Config.Debug then print(('[jvl_sales] %s sold %s items for $%s'):format(GetPlayerName(source), units, total)) end
    return { ok = true, msg = 'ok_sold', args = { units, total } }
end)

AddEventHandler('playerDropped', function()
    lastSale[source] = nil
end)
