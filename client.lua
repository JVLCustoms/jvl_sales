--#####################################################--
--#- Created by Hamza & Optimized by JVL Customs -----#--
--#------- Updated with new HTML interface -----------#--
--#####################################################--
ESX = exports["es_extended"]:getSharedObject()

-- Global variables
local isOpen = false
local playerFrozen = false

-- Function to get player inventory
local function GetPlayerInventory()
    local inventory = {}
    local xPlayer = ESX.GetPlayerData()
    
    if xPlayer and xPlayer.inventory then
        for _, item in pairs(xPlayer.inventory) do
            if item.count > 0 then
                table.insert(inventory, {
                    name = item.name,
                    label = item.label,
                    count = item.count
                })
            end
        end
    end
    
    return inventory
end

-- Function to open new sales interface
function OpenSalesInterface()
    if isOpen then return end
    
    isOpen = true
    local player = PlayerPedId()
    FreezeEntityPosition(player, true)
    playerFrozen = true
    
    -- Get player inventory
    local inventory = GetPlayerInventory()
    
    -- Prepare sell items (items that can be sold)
    local sellItems = {}
    for _, item in pairs(Config.ItemsInjvl_sales) do
        if item.SellInjvl_sales then
            table.insert(sellItems, {
                itemName = item.itemName,
                label = item.label,
                SellPrice = item.SellPrice
            })
        end
    end
    
    -- Open NUI
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "openSalesMenu",
        sellItems = sellItems,
        inventory = inventory,
        imageBasePath = Config.ImageBasePath or 'nui://ox_inventory/web/images/'
    })
end

-- Function to close interface
function CloseSalesInterface()
    if not isOpen then return end
    
    isOpen = false
    SetNuiFocus(false, false)
    
    local player = PlayerPedId()
    FreezeEntityPosition(player, false)
    playerFrozen = false
    
    SendNUIMessage({
        type = "closeSalesMenu"
    })
end

-- NUI Callbacks
RegisterNUICallback('closeMenu', function(data, cb)
    CloseSalesInterface()
    cb('ok')
end)

RegisterNUICallback('sellItem', function(data, cb)
    if not data.itemName or not data.quantity or not data.totalPrice then
        cb('error')
        return
    end
    
    TriggerServerEvent("jvl_sales:SellItem", data.quantity, data.totalPrice, data.itemName)
    cb('ok')
end)

-- Update inventory when it changes
RegisterNetEvent('esx:setPlayerData')
AddEventHandler('esx:setPlayerData', function(key, value)
    if key == 'inventory' and isOpen then
        local inventory = GetPlayerInventory()
        SendNUIMessage({
            type = "updateInventory",
            inventory = inventory
        })
    end
end)

-- Modified sell menu function to use new interface
function jvl_salesSellMenu()
    if Config.UseNewInterface ~= false then
        OpenSalesInterface()
        return
    end
    
    -- Original menu code (fallback)
    local player = PlayerPedId()
    FreezeEntityPosition(player, true)
    local elements = {}

    for k, v in pairs(Config.ItemsInjvl_sales) do
        if v.SellInjvl_sales == true then
            table.insert(elements, {
                label = v.label .. " | " .. ('<span style="color:green;">%s</span>'):format("$" .. v.SellPrice .. ""),
                itemName = v.itemName,
                SellInjvl_sales = v.SellInjvl_sales,
                SellPrice = v.SellPrice
            })
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), "jvl_sales_sell_menu",
        {
            title = "¿Qué quieres vender?",
            align = "top-left",
            elements = elements
        },
    function(data, menu)
        if data.current.itemName then
            OpenSellDialogMenu(data.current.itemName, data.current.SellPrice)
        end
    end, function(data, menu)
        menu.close()
        FreezeEntityPosition(player, false)
    end)
end

-- Legacy dialog menu (keeping for fallback)
function OpenSellDialogMenu(itemName, SellPrice)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'jvl_sales_amount_to_sell_dialog', {
        title = "Cantidad a vender?"
    }, function(data, menu)
        local amountToSell = tonumber(data.value)
        
        if not amountToSell or amountToSell <= 0 then
            TriggerEvent('esx:showNotification', 'Cantidad inválida.')
        else
            local totalSellPrice = (SellPrice * amountToSell)
            TriggerServerEvent("jvl_sales:SellItem", amountToSell, totalSellPrice, itemName)
        end

        menu.close()
    end, function(data, menu)
        menu.close()
    end)
end

-- Crear NPC y registrar una zona interactiva con ox_target
Citizen.CreateThread(function()
    for _, v in pairs(Config.SellZones) do
        local pedCoords = v.Ped.Coords
        local pedHeading = pedCoords.w
        local pedHash = GetHashKey(v.Ped.Model)

        RequestModel(pedHash)
        while not HasModelLoaded(pedHash) do
            Citizen.Wait(10)
        end
        
        local npc = CreatePed(4, pedHash, pedCoords.x, pedCoords.y, pedCoords.z - 1.0, pedHeading, false, true)
        if DoesEntityExist(npc) then
            SetEntityAsMissionEntity(npc, true, true)
            SetBlockingOfNonTemporaryEvents(npc, true)
            FreezeEntityPosition(npc, true)
            SetEntityInvincible(npc, true)
            TaskStartScenarioInPlace(npc, "WORLD_HUMAN_CLIPBOARD", 0, true)
        end
        
        exports.ox_target:addSphereZone({
            coords = vector3(pedCoords.x, pedCoords.y, pedCoords.z),
            radius = 1.5,
            options = {
                {
                    name = 'jvl_sales',
                    icon = 'fa-solid fa-dollar-sign',
                    label = 'Abrir menú de venta',
                    onSelect = function()
                        jvl_salesSellMenu()
                    end,
                    canInteract = function(entity, distance, coords, name)
                        return true
                    end
                }
            },
            debug = false
        })
        
        SetModelAsNoLongerNeeded(pedHash)
    end
end)

-- Crear Blips en el Mapa
Citizen.CreateThread(function()
    if Config.Enablejvl_salesBlip then
        for k, v in pairs(Config.SellZones) do
            local blip = AddBlipForCoord(v.Pos.x, v.Pos.y, v.Pos.z)
            SetBlipSprite(blip, Config.BlipSprite)
            SetBlipDisplay(blip, Config.BlipDisplay)
            SetBlipScale(blip, Config.BlipScale)
            SetBlipColour(blip, Config.BlipColour)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.BlipName)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- Clean up when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    if isOpen then
        SetNuiFocus(false, false)
        local player = PlayerPedId()
        FreezeEntityPosition(player, false)
        isOpen = false
    end
end)

