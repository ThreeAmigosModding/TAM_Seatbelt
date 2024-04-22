local config = {}

config.blacklistedClasses = { -- the classes that don't have a seatbelt.
    8,
    13,
    14
}

config.keyboardBind = "X" -- keyboard bind. ref: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

config.controllerBind = "RDOWN_INDEX" -- controller bind. ref: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/pad_digitalbutton/

config.checkSeatbeltCommand = "checkseatbelt" -- command to check if the driver of the nearest vehicle is wearing their seatbelt.

-- Language config is in locales/ directory.

return config