--#####################################################--
--#- Created by Hamza & Optimized by JVL Customs -----#--
--#------- Updated with new HTML interface -----------#--
--#####################################################--
ESX = exports["es_extended"]:getSharedObject()

-- Server Event for Selling:
RegisterServerEvent("jvl_sales:SellItem")
AddEventHandler("jvl_sales:SellItem", function(amountToSell, totalSellPrice, itemName)
    local xPlayer = ESX.GetPlayerFromId(source)

    if not xPlayer then
        print("Error: Jugador no encontrado.")
        return
    end

    -- Validar cantidad de venta
    if amountToSell == nil or amountToSell <= 0 then
        TriggerClientEvent("esx:showNotification", source, "Cantidad no válida.")
        return
    end

    -- Verificar que el ítem sea válido
    local validItem = false
    for _, v in pairs(Config.ItemsInjvl_sales) do
        if v.itemName == itemName then
            validItem = true
            break
        end
    end

    if not validItem then
        print("Intento de venta con un item no válido: " .. tostring(itemName))
        return
    end

    -- Verificar que el jugador tenga suficientes ítems en el inventario
    local itemLabel = ESX.GetItemLabel(itemName)
    local inventoryItem = xPlayer.getInventoryItem(itemName)

    if inventoryItem.count >= amountToSell then
        xPlayer.addMoney(totalSellPrice)
        xPlayer.removeInventoryItem(itemName, amountToSell)
        TriggerClientEvent("esx:showNotification", source, "Vendiste "..amountToSell.."x"..itemLabel.." por $"..totalSellPrice.."")
    else
        TriggerClientEvent("esx:showNotification", source, "No tienes suficientes artículos.")
    end
end)
