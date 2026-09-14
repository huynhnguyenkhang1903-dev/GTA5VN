resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ES SnapeVN'

version '1.1.0'

client_scripts {
	'config.lua',
	'config_bone.lua',
	'config.award_level.lua',
	'client/notice.lua',
	'client/global_function.lua',
	--'client/arrest_ani.lua',
	--'client/damage.lua',
	'client/client.lua',
	--'client/safezone.lua',
	'client/online.lua',
	'client/vehicle_control.lua',
	'client/weapon_name.lua',
}

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'config.lua',
	'config.award_level.lua',
	'server/distance.lua',
	'server/server.lua',
	'server/autochat.lua'
}

exports {
	'ChangeSkin',
	'InSafeZone',
	'IsPosInSafeZone',
	'GetDistNearSafeZone'
}

server_exports {
	'UserLog',
	'AddPersonVehicle',
	'RegisterPlateVehicle'
}

dependencies {
	'mysql-async'
}
