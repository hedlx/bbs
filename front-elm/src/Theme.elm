module Theme exposing (ID, Theme, builtIn, default)

import Dict exposing (Dict)
import Tachyons.Classes exposing (..)


type alias Theme =
    { id : ID
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
    , fgMenuButton : String
    , fgMenuButtonDisabled : String
    , fgTextButton : String
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
    , fgSettings : String
    , bgSettings : String
    }


type alias ID =
    String


builtIn : Dict ID Theme
builtIn =
    Dict.fromList
        [ ( themeDark.id, themeDark )
        , ( themeLight.id, themeLight )
        ]


default : Theme
default =
    themeDark


themeDark : Theme
themeDark =
    { id = "builtInDark"
    , name = "Dark"
    , font = system_sans_serif
    , fontMono = code
    , fg = darkMainFG
    , bg = bg_near_black
    , fgAlert = red
    , fgSpinner = darkMainFG
    , fgOpName = white
    , fgThreadNo = green
    , fgThreadSubject = pink
    , fgPostNo = darkMainFG
    , fgPost = darkMainFG
    , fgPostHead = darkMainFG
    , fgPostName = light_blue
    , fgPostTrip = white
    , bgPost = bg_dark_gray
    , fgMenu = darkMainFG
    , bgMenu = bg_black_30
    , fgMenuButton = white_80
    , fgMenuButtonDisabled = white_20
    , fgTextButton = white_80
    , fgButton = white_80
    , bgButton = bg_dark_gray
    , fgButtonDisabled = white_20
    , bgButtonDisabled = bg_near_black
    , fgInput = darkMainFG
    , bgInput = bg_black_30
    , bInput = b__white_10
    , fgPopUpWarn = white
    , bgPopUpWarn = bg_orange
    , fgPopUpErr = white
    , bgPopUpErr = bg_red
    , fgSettings = darkMainFG
    , bgSettings = bg_black
    }


darkMainFG : String
darkMainFG =
    light_silver


themeLight : Theme
themeLight =
    { id = "builtInLight"
    , name = "Light"
    , font = system_sans_serif
    , fontMono = code
    , fg = lightMainFG
    , bg = bg_washed_yellow
    , fgAlert = red
    , fgSpinner = purple
    , fgOpName = purple
    , fgThreadNo = purple
    , fgThreadSubject = red
    , fgPostNo = lightMainFG
    , fgPost = lightMainFG
    , fgPostHead = lightMainFG
    , fgPostName = dark_green
    , fgPostTrip = purple
    , bgPost = bg_washed_red
    , fgMenu = lightMainFG
    , bgMenu = bg_purple
    , fgMenuButton = white
    , fgMenuButtonDisabled = white_20
    , fgTextButton = purple
    , fgButton = white
    , bgButton = bg_purple
    , fgButtonDisabled = b__black_20
    , bgButtonDisabled = bg_black_20
    , fgInput = lightMainFG
    , bgInput = bg_white
    , bInput = b__black_40
    , fgPopUpWarn = white
    , bgPopUpWarn = bg_orange
    , fgPopUpErr = white
    , bgPopUpErr = bg_red
    , fgSettings = white
    , bgSettings = bg_purple
    }


lightMainFG : String
lightMainFG =
    dark_gray