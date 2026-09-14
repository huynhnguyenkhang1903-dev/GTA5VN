resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ES Extended'

version '1.1.0'

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',

	'locale.lua',
	'locales/en.lua',

	'config.lua',
	'config.fn.lua',
	'config.weapons.lua',
	'config.level.lua',
	
	'server/cmds.lua',
	'server/common.lua',
	'server/classes/group.lua',
	'server/classes/player.lua',
	'server/functions.lua',
	'server/vehicles.lua',
	'server/paycheck.lua',

	'common/modules/math.lua',
	'common/modules/table.lua',
	'common/functions.lua',

	'server/main.lua',
	'server/commands.lua'
}

client_scripts {
	'locale.lua',
	'locales/en.lua',
	
	'@polyzone/client.lua',
	'@polyzone/BoxZone.lua',
	'@polyzone/EntityZone.lua',
	'@polyzone/CircleZone.lua',
	'@polyzone/ComboZone.lua',

	'config.lua',
	'config.weapons.lua',
	'config.level.lua',

	'client/common.lua',
	'client/entityiter.lua',
	'client/functions.lua',
	'client/system.lua',
	'client/vehicles.lua',
	'client/levelsystem.lua',
	'client/wrapper.lua',

	'common/modules/math.lua',
	'common/modules/table.lua',
	'common/functions.lua',

	'client/main.lua',
	
	'client/compass.lua',
	'client/modules/death.lua',
	'client/modules/scaleform.lua',
	'client/modules/streaming.lua',
}

ui_page {
	'html/ui.html'
}

files {
	'items.json',
	'locale.js',
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',

	'html/img/accounts/bank.png',
	'html/img/accounts/black_money.png'
}

exports {
	'getSharedObject'
}

server_exports {
	'getSharedObject',
	'AddVehiclePersonal',
	'UpdateVehicleProps',
	'UpdateVehiclePersonal',
	'GetVehiclesPersonal',
	'GetVehiclePersonal',
	'CreatePersonVehicle',
	'RemoveAllVehicleFromGarage',
	'GetVehiclePersonalByGarage',
	'GetVehiclePersonalEntity',
	'GetPlayerVehiclesFree',
	'GetGarageVehicleExpired',
	'ChangeOwnerVehicle'
}

dependencies {
	'mysql-async',
	'async'
}
