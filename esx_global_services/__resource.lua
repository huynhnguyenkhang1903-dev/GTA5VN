resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX GTA5VN Services'

version '1.0.0'

server_scripts {
	'server/main.lua',
  'config.lua'
}

client_scripts {
	'client/main.lua'
}

server_exports {
	'CancelServiceWithName',
	'RegisterBecomeWorker',
	'UnregisterBecomeWorker'
}

ui_page 'html/mechanic_panel.html'

files {
  'html/*',
  'html/fonts/*',
  'html/images/*'
}