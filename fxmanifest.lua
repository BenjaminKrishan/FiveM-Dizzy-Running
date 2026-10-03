fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'
author 'Benjamin Krishan'
description 'BenX Development Dizzy Running Script © 2026'
version '2.0.0'
repository 'https://github.com/BenjaminKrishan'
discord 'https://discord.gg/5vH5qq6RSV'

shared_scripts {
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
    'config.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

dependencies {
    'qbx_core',
    'ox_lib',
    'ox_target',
    'ox_inventory'
    
}