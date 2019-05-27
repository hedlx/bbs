module Theme exposing (ID, Theme, builtIn, decoder, default, encode, selectBuiltIn)

import Dict exposing (Dict)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode
import Tachyons.Classes exposing (..)


type alias Theme =
    { id : ID
    , name : String
    , font : String
    , fontMono : String
    , fg : String
    , bg : String
    , fgRemark : String
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
    , bgButtonHover : String
    , fgButtonDisabled : String
    , bgButtonDisabled : String
    , fgInput : String
    , bgInput : String
    , bInput : String
    , fgSlideInWarn : String
    , bgSlideInWarn : String
    , fgSlideInErr : String
    , bgSlideInErr : String
    , fgDialog : String
    , bgDialog : String
    , shadowSettings : String
    }


type alias ID =
    String


builtIn : Dict ID Theme
builtIn =
    Dict.fromList <|
        List.map (\theme -> ( theme.id, theme ))
            [ themeDark
            , themeLight
            ]


default : Theme
default =
    themeDark


selectBuiltIn : ID -> Theme
selectBuiltIn themeID =
    Dict.get themeID builtIn
        |> Maybe.withDefault default


decoder : Decoder Theme
decoder =
    Decode.map selectBuiltIn Decode.string


encode : Theme -> Encode.Value
encode theme =
    Encode.string theme.id


themeDark : Theme
themeDark =
    { id = "builtInDark"
    , name = "Dark"
    , font = system_sans_serif
    , fontMono = code
    , fg = darkMainFG
    , bg = bg_near_black
    , fgRemark = white_30
    , fgAlert = red
    , fgSpinner = darkMainFG
    , fgOpName = light_blue
    , fgThreadNo = green
    , fgThreadSubject = pink
    , fgPostNo = darkMainFG
    , fgPost = darkMainFG
    , fgPostHead = darkMainFG
    , fgPostName = light_blue
    , fgPostTrip = white
    , bgPost = bg_dark_gray
    , fgMenu = darkMainFG
    , bgMenu = bg_black
    , fgMenuButton = white_80
    , fgMenuButtonDisabled = white_20
    , fgTextButton = white_80
    , fgButton = white_80
    , bgButton = bg_dark_gray
    , bgButtonHover = hover_bg_mid_gray
    , fgButtonDisabled = white_20
    , bgButtonDisabled = bg_near_black
    , fgInput = darkMainFG
    , bgInput = bg_black_30
    , bInput = b__white_10
    , fgSlideInWarn = white
    , bgSlideInWarn = bg_orange
    , fgSlideInErr = white
    , bgSlideInErr = bg_red
    , fgDialog = silver
    , bgDialog = bg_black
    , shadowSettings = shadow_1
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
    , fgRemark = black_50
    , fgAlert = red
    , fgSpinner = dark_red
    , fgOpName = dark_blue
    , fgThreadNo = purple
    , fgThreadSubject = purple
    , fgPostNo = lightMainFG
    , fgPost = lightMainFG
    , fgPostHead = lightMainFG
    , fgPostName = dark_blue
    , fgPostTrip = purple
    , bgPost = bg_washed_red
    , fgMenu = lightMainFG
    , bgMenu = bg_purple
    , fgMenuButton = white
    , fgMenuButtonDisabled = white_20
    , fgTextButton = purple
    , fgButton = white
    , bgButton = bg_red
    , bgButtonHover = hover_bg_dark_red
    , fgButtonDisabled = b__black_20
    , bgButtonDisabled = bg_black_20
    , fgInput = lightMainFG
    , bgInput = bg_white
    , bInput = b__black_40
    , fgSlideInWarn = white
    , bgSlideInWarn = bg_orange
    , fgSlideInErr = white
    , bgSlideInErr = bg_red
    , fgDialog = white
    , bgDialog = bg_purple
    , shadowSettings = shadow_5
    }


lightMainFG : String
lightMainFG =
    dark_gray
