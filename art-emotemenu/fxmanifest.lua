fx_version 'cerulean'
game 'gta5'

author 'ArtseeN'
description 'Status System'

dependencies {
    'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

lua54 'yes' 