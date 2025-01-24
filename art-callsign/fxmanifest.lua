fx_version 'cerulean'
game 'gta5'

author 'ArtseeN'
description 'polis araçlarına çağrı kodu ekleme scripti.'
version '1.0.0'


client_scripts {
    'callsign_client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'callsign.lua'
}

-- QBCore Bağımlılığı
dependencies {
    'qb-core'
}
