resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX BirthdayJob by SnapeVN'

version '1.0.0'

server_scripts {
	'@salty_tokenizer/init.lua',
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'server.lua'
}

client_scripts {
	'@salty_tokenizer/init.lua',
	'config.lua',
	'client.lua'
}
