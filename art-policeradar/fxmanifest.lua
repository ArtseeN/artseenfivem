fx_version 'cerulean'
game 'gta5'

author 'ArtseeN'
description 'Polis Radar Sistemi'
version '1.0.0'


client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- MySQL bağlantısı için gerekli
    'server.lua'
}


ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/style.css',
    'html/script.js'
}

dependencies {
    'qb-core', 
}
