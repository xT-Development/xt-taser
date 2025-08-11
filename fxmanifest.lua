fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author 'xT Development'
description 'Reloadable Stun Guns'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua',
}

files {
    'config.lua',
    'ui/index.html',
    'ui/script.js',
    'ui/style.css'
}

ui_page 'ui/index.html'