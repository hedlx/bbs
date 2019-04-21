module Theme exposing (Theme, builtIn, empty)

import Dict exposing (Dict)
import Tachyons.Classes exposing (..)


type alias Theme =
    { id : String
    , name : String
    , font : String
    , fontMono : String
    , fg : String
    , bg : String
    , fgAlert : String
    , fgSpinner : String
    , fgOpName : String
    , fgThreadNo : String
    , fgThreadSubject : String
    , fgPostNo : String
    , fgPost : String
    , fgPostHead : String
    , fgPostName : String
    , fgPostTrip : String
    , bgPost : String
    , fgMenu : String
    , bgMenu : String
    , fgButton : String
    , bgButton : String
    , fgButtonDisabled : String
    , bgButtonDisabled : String
    , fgInput : String
    , bgInput : String
    , bInput : String
    , fgPopUpWarn : String
    , bgPopUpWarn : String
    , fgPopUpErr : String
    , bgPopUpErr : String
    }


builtIn : Dict String Theme
builtIn =
    Dict.fromList
        [ ( empty.id, empty )
        ]


empty : Theme
empty =
    themeDark


themeDark : Theme
themeDark =
    { id = "builtInDark"
    , name = "Dark"
    , font = system_sans_serif
    , fontMono = code
    , fg = light_silver
    , bg = bg_near_black
    , fgAlert = red
    , fgSpinner = light_silver
    , fgOpName = white
    , fgThreadNo = green
    , fgThreadSubject = pink
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
    , fgPopUpWarn = white
    , bgPopUpWarn = bg_orange
    , fgPopUpErr = white
    , bgPopUpErr = bg_red
    }
