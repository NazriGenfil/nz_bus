fx_version 'cerulean'
game 'gta5'

version '1.0.2'

ui_page 'html/meter.html'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    "client/*.lua",
    "client/target/*.lua",
}
    

server_script 'server/*.lua'

files {
	'html/meter.css',
	'html/meter.html',
	'html/meter.js',
	'html/reset.css',
	'html/g5-meter.png'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'