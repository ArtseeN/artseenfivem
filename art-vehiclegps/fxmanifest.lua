fx_version 'cerulean'
game 'gta5'

author 'Sizin İsminiz'
description 'QBCore Araç GPS Sistemi'
version '1.0.0'

shared_scripts {
    'config.lua',
    '@qb-core/import.lua'
}

server_scripts {
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}

dependencies {
    'qb-core'
} 