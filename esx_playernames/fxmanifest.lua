fx_version 'adamant'

game "gta5"

description "New Player Name System by SnapeVN"

client_scripts {
	'shared.lua',
	"client.lua"
}

server_script {
	'@mysql-async/lib/MySQL.lua',
	'shared.lua',
	'server.lua'
}

server_exports {
	'GetHeadMoney',
	'RemoveHeadMoney',
	'AddHeadMoney',
	'GetWanted'
}