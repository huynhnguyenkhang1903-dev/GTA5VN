fx_version 'adamant'

game "gta5"

description "Prison by SnapeVN"

client_scripts {
	'@salty_tokenizer/init.lua',
	'@polyzone/client.lua',
	'config.lua',
	'client.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@salty_tokenizer/init.lua',
	'config.lua',
	'server.lua',
}

exports {
	'GetJailTime',
	'IsNeedInJail'
}

server_exports {
	'SetNeedInJail',
	'JailPlayer'
}