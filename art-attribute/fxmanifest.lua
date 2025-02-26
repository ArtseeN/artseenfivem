fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'ArtseeN'
description 'Karakter Özellik Sistemi'
version '1.0.0'

shared_scripts {
    '@qb-core/shared/locale.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'attribute_system.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'attribute_system_server.lua'
}

dependencies {
    'qb-core',
    'ox_lib',
    'oxmysql'
} 