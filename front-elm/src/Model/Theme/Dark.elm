module Model.Theme.Dark exposing (theme)

import Tachyons.Classes exposing (..)


theme =
    { id = "builtInDark"
    , name = "Dark"
    , font = system_sans_serif
    , fontMono = code
    , fg = light_silver
    , bg = bg_near_black
    , fgOpName = green
    , fgPost = light_silver
    , fgPostHead = light_silver
    , fgPostName = light_blue
    , fgPostTrip = gray
    , bgPost = bg_dark_gray
    , fgMenu = light_silver
    , bgMenu = bg_black_30
    , fgButton = white_80
    , bgButton = bg_dark_gray
    , fgInput = light_silver
    , bgInput = bg_black_30
    , bInput = b__white_10
    }
