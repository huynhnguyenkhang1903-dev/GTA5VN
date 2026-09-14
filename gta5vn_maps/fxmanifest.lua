fx_version 'bodacious'
game 'gta5'

author 'SnapeVN'
description 'Global map for GTA5VN'
version '1.0.0'

this_is_a_map 'yes'


data_file 'TIMECYCLEMOD_FILE' 'gabz_mrpd_timecycle.xml'
--data_file 'OVERLAY_INFO_FILE' 'overlayinfo.xml'
data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'
data_file 'GTXD_PARENTING_DATA' 'gtxd.meta'

files {
	'gabz_mrpd_timecycle.xml',
	'interiorproxies.meta',
	--'overlayinfo.xml',
	'gtxd.meta'
}

client_script {
    "gabz_mrpd_entitysets.lua"
}