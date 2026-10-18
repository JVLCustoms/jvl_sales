--[[
    Shared helpers: framework detection, translations and the buyer's price list.
]]

JvlSales = JvlSales or {}

local frameworks = {
    { name = 'qbox', resource = 'qbx_core' },
    { name = 'qb', resource = 'qb-core' },
    { name = 'esx', resource = 'es_extended' },
}

local function detectFramework()
    if Config.Framework ~= 'auto' then return Config.Framework end
    for _, entry in ipairs(frameworks) do
        if GetResourceState(entry.resource) == 'started' then return entry.name end
    end
    return 'standalone'
end

JvlSales.Framework = detectFramework()

local locale = Config.Locale
if locale == 'auto' then
    if IsDuplicityVersion() then
        locale = 'es'
    else
        local gameLanguages = { [0] = 'en', 'fr', 'de', 'it', 'es', 'pt', 'pl', 'ru', 'ko', 'zh', 'ja', 'es', 'zh' }
        locale = gameLanguages[GetCurrentLanguage()] or 'en'
    end
end
if not Locales[locale] then locale = 'en' end
JvlSales.Locale = locale

function L(key, ...)
    local text = (Locales[locale] and Locales[locale][key]) or (Locales.es and Locales.es[key]) or key
    if select('#', ...) > 0 then return text:format(...) end
    return text
end

--- Price list of a buyer: { [item] = { item, price, label? } }
function JvlSales.PriceList(buyerIndex)
    local buyer = Config.Buyers[buyerIndex]
    if not buyer then return nil end
    local allowed
    if buyer.items then
        allowed = {}
        for _, name in ipairs(buyer.items) do allowed[name] = true end
    end
    local list = {}
    for _, entry in ipairs(Config.Items) do
        if not allowed or allowed[entry.item] then list[entry.item] = entry end
    end
    return list
end
