game 'gta5'
lua54 'yes'
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'

description 'Boat Anchors for FiveM'
author 'xT Development | dsc.gg/xtdev'

shared_scripts { '@ox_lib/init.lua' }

client_scripts {
    'config.lua',
    'client/*.lua'
}

server_scripts { 'server/*.lua' }