fx_version 'cerulean'
games { 'gta5' }

name 'admin_car'
author 'Antigravity'
description 'Admin Personal Garage & Fast Vehicle Spawner with Full Tuning Persistence'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/default_car.svg'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/vehicle_props.lua',
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}
