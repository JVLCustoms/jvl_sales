--[[
    JVL Sales - configuration
    NPC buyers: players sell items from their inventory at fixed prices.
    Prices, items and distance are checked on the server; the panel only shows them.

    Multiframework: Qbox, QBCore and ESX (auto-detected). Inventory: ox_inventory, qb-inventory or ESX.
    ox_target or qb-target. No fxmanifest dependencies.
]]

Config = {}

Config.Framework = 'auto' -- 'auto' | 'qbox' | 'qb' | 'esx'
Config.Locale = 'auto'    -- 'auto' = the player's GTA V language | 'es' | 'en'
Config.Debug = false

Config.Target = 'auto'    -- 'auto' | 'ox_target' | 'qb-target'
Config.TargetDistance = 2.0
Config.ServerDistance = 6.0          -- max distance to the buyer the server accepts
Config.PayAccount = 'cash'           -- 'cash' | 'bank'
Config.MaxPerSale = 1000             -- max units of one item per sale
Config.ImagePath = 'nui://ox_inventory/web/images/%s.png' -- item pictures ('' = no pictures)
Config.LogoUrl = 'https://r2.fivemanage.com/X1XK135fBbC6NDyRj5dwS/logomediacode.png' -- header logo ('' = Config.Icon)
Config.Icon = 'fa-solid fa-recycle' -- Font Awesome icon used when there is no logo

-- Items bought by the buyers. label = optional (the inventory label is used otherwise)
Config.Items = {
    { item = 'garbage', price = 3 },
    { item = 'burger', price = 15 },
    { item = 'scrapmetal', price = 25 },
    { item = 'estetoscopio', price = 150 },
    { item = 'empty_bottle', price = 10 },
    { item = 'mustard', price = 5 },
}

-- Buyers. items = optional list of item names this buyer accepts (nil = every item above)
Config.Buyers = {
    {
        label = 'Venta de Materiales',
        ped = { model = 'a_m_y_salton_01', coords = vector4(-340.63, -1543.86, 27.72, 100.05), scenario = 'WORLD_HUMAN_CLIPBOARD' },
        blip = { sprite = 365, colour = 2, scale = 0.8 }, -- false = no blip
        items = nil,
    },
}

--- Notification (client): jvl_notify first, then ox_lib.
function Notify(message, type)
    if GetResourceState('jvl_notify') == 'started' then
        exports['jvl_notify']:ShowNotification(type or 'info', L('notify_title'), message, 5000)
    else
        TriggerEvent('ox_lib:notify', { title = L('notify_title'), description = message, type = type == 'info' and 'inform' or type })
    end
end
