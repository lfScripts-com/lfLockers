fx_version 'cerulean'
game 'gta5'
author 'LFScripts, xLaugh, Firgyy'
shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'lang.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}