resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

client_script 'client.lua'
client_script 'config.lua'

server_script 'config.lua'
server_script 'server.lua'

ui_page {
  'gui/index.html'
}

files {
  'gui/index.html',

  'gui/main.css',

  'gui/main.js',

  'gui/fonts/VCR_OSD_MONO.ttf',

  'gui/fonts/BalooDa-Regular.ttf',
  
  'gui/alert.mp3',

  'gui/logo.png',
  'gui/bg.gif',
  'gui/animate.css'
}
