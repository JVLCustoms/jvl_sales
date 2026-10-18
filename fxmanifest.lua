fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jvl_sales'
author 'JVL MediaCode'
description 'JVL Sales - NPC buyers for inventory items at fixed prices (Qbox, QBCore, ESX)'
version '3.1.0'

-- Runtime: ox_lib, ox_inventory (or qb / ESX inventory), ox_target or qb-target. No fxmanifest dependencies.
shared_scripts {
    '@ox_lib/init.lua',
    'locales/*.lua',
    'config.lua',
    'shared/utils.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/jvl-steel-blue.css',
    'web/style.css',
    'web/script.js',
}
