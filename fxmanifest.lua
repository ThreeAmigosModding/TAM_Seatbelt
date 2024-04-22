--[[------------------------------------------------------
----       For Support - discord.gg/threeamigos       ----
---- Do not edit if you do not know what you"re doing ----
--]]------------------------------------------------------

fx_version "cerulean"
use_experimental_fxv2_oal "yes"
lua54 "yes"
game "gta5"

name "TAM_Seatbelt"
author "ThreeAmigosModding"
description "Simple seatbelt with LEO detection."
version "1.0.0"

client_debug_mode "false"
server_debug_mode "false"
experimental_features_enabled "0"

files {
    "data/*",
    "locales/*.json",
    "client/ui/*.html",
    "client/ui/*.js",
    "client/ui/*.css",
    "client/ui/*.svg",
    "audiodata/tam_seatbelt.dat54.rel",
    "audiodirectory/tam_seatbelt.awc"
}

data_file "AUDIO_WAVEPACK" "audiodirectory"
data_file "AUDIO_SOUNDDATA" "audiodata/tam_seatbelt.dat"

ui_page "client/ui/index.html"

shared_scripts {
   "@ox_lib/init.lua"
}

client_scripts {
    "client/main.lua"
}

server_scripts {
    "server/main.lua"
}