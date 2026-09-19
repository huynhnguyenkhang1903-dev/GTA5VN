resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

this_is_a_map 'yes'


files {

    "interiorproxies.meta"
}
    
data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'

    

--[[
client_scripts {
	-- '@es_extended/locale.lua',
	'locales/fr.lua',
	'client/GUI.lua',
	'config.lua',
	'client/client.lua'
}

server_scripts {
	-- '@es_extended/locale.lua',
	'config.lua'
}
--]]