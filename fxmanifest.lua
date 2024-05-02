fx_version 'cerulean'

game 'gta5'

ui_page 'html/index.html'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
}

files {
    'html/*',
}

dependency 'qb-target'
