fx_version 'cerulean'
game 'gta5'
author 'LFScripts, xLaugh, Firgyy'
lua54 'yes'
escrow_ignore {
    'client.lua',
    'server.lua',
    'config.lua',
    'lang.lua',
  }

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
}
