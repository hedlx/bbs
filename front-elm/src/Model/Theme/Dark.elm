module Model.Theme.Dark exposing (theme)

import Tachyons.Classes exposing (..)


theme =
    { id = "builtInDark"
    , name = "Dark"
    , font = system_sans_serif
    , fontMono = code
    , fg = light_silver
    , bg = bg_near_black
    , fgAlert = red
    , fgOpName = green
    , fgThreadNo = green
    , fgPostNo = light_silver
    , fgPost = light_silver
    , fgPostHead = light_silver
    , fgPostName = light_blue
    , fgPostTrip = white
    , bgPost = bg_dark_gray
    , fgMenu = light_silver
    , bgMenu = bg_black_30
    , fgButton = white_80
    , bgButton = bg_dark_gray
    , fgButtonDisabled = white_20
    , bgButtonDisabled = bg_near_black
    , fgInput = light_silver
    , bgInput = bg_black_30
    , bInput = b__white_10
    }
