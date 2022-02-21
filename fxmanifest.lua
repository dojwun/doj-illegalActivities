
fx_version 'cerulean'

game 'gta5'

server_script 'server/*.lua' 

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
    'client/*.lua',
	'client/moonshine/*.lua',
}

shared_scripts { 
	'config.lua',
}

lua54 'yes'
