fx_version 'cerulean'
game 'gta5'

author 'ArtseeN DC: weturnhell'
description 'Police/Sheriff Vehicle GPS System'
version '1.0.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

lua54 'yes' 