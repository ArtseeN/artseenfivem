fx_version 'cerulean'
game 'gta5'

description 'Art-DeliveryJob'
version '1.0.0'

ui_page 'html/index.html'

shared_script 'config.lua'
client_scripts {
    'config.lua',
    'client.lua'
}
server_script 'server.lua'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
} 