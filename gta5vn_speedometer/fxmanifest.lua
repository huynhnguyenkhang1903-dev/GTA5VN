fx_version 'cerulean'
games { 'gta5' }

name 'gta5vn_speedometer'
author 'Antigravity'
description 'GTA5VN Luxury Sport Speedometer & Vehicle HUD with Seatbelt System'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua'
}
