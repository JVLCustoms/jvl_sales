--#####################################################--
--#- Created by Hamza & Optimized by JVL Customs -----#--
--#------- Updated with new HTML interface -----------#--
--#####################################################--

fx_version 'cerulean'
game 'gta5'

author 'JVL Customs'
description 'Simple y configurable sales system with modern interface'
version '2.0.0'

-- Habilitar Lua 5.4 (si lo necesitas)
lua54 'yes'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}

shared_script '@es_extended/imports.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/styles.css',
    'html/script.js',
    'html/img/*.png'
}

dependencies {
    'ox_target'
}