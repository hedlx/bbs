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
    , fgThreadSubject : String
    , bSeparator : String
    , fgPostNo : String
    , fgPost : String
    , fgPostHead : String
    , fgPostName : String
    , fgPostTrip : String
    , bgPost : String
    , bFocusedPost : String
    , fgQuote : String
    , fgMenu : String
    , bgMenu : String
    , shadowMenu : String
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
    , bDialog : String
    , shadowSettings : String
    }


type alias ID =
    String


builtIn : Dict ID Theme
builtIn =
    Dict.fromList <|
        List.map (\theme -> ( theme.id, theme ))
            [ themeVoid
            , themeSkylight
            , themeLunatic
            ]


default : Theme
default =
    themeVoid


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


themeVoid : Theme
themeVoid =
    { id = "builtInVoid"
    , name = "Void"
    , font = system_sans_serif
    , fontMono = code
    , fg = darkMainFG
    , bg = bg_black_90
    , fgRemark = white_30
    , fgAlert = red
    , fgSpinner = darkMainFG
    , fgOpName = light_blue
    , fgThreadSubject = pink
    , bSeparator = b__white_20
    , fgPostNo = darkMainFG
    , fgPost = darkMainFG
    , fgPostHead = darkMainFG
    , fgPostName = light_blue
    , fgPostTrip = white
    , bgPost = bg_dark_gray
    , bFocusedPost = b__blue
    , fgQuote = gray
    , fgMenu = darkMainFG
    , bgMenu = bg_dark_gray
    , shadowMenu = shadow_2
    , fgMenuButton = white_80
    , fgMenuButtonDisabled = black_20
    , fgTextButton = white_80
    , fgButton = white_80
    , bgButton = bg_dark_gray
    , bgButtonHover = hover_bg_mid_gray
    , fgButtonDisabled = white_20
    , bgButtonDisabled = bg_near_black
    , fgInput = darkMainFG
    , bgInput = bg_near_black
    , bInput = b__white_10
    , fgSlideInWarn = white
    , bgSlideInWarn = bg_orange
    , fgSlideInErr = white
    , bgSlideInErr = bg_red
    , fgDialog = light_silver
    , bgDialog = bg_dark_gray
    , bDialog = b__light_blue
    , shadowSettings = shadow_5_ns
    }


darkMainFG : String
darkMainFG =
    light_silver


themeSkylight : Theme
themeSkylight =
    { id = "builtInSkylight"
    , name = "Skylight"
    , font = system_sans_serif
    , fontMono = code
    , fg = lightMainFG
    , bg = bg_washed_blue
    , fgRemark = black_50
    , fgAlert = red
    , fgSpinner = blue
    , fgOpName = dark_blue
    , fgThreadSubject = dark_pink
    , bSeparator = b__blue
    , fgPostNo = lightMainFG
    , fgPost = lightMainFG
    , fgPostHead = lightMainFG
    , fgPostName = dark_blue
    , fgPostTrip = navy
    , bgPost = bg_lightest_blue
    , bFocusedPost = b__pink
    , fgQuote = green
    , fgMenu = lightMainFG
    , bgMenu = bg_blue
    , shadowMenu = ""
    , fgMenuButton = white
    , fgMenuButtonDisabled = black_10
    , fgTextButton = dark_blue
    , fgButton = white
    , bgButton = bg_light_red
    , bgButtonHover = hover_bg_red
    , fgButtonDisabled = black_20
    , bgButtonDisabled = bg_lightest_blue
    , fgInput = lightMainFG
    , bgInput = bg_white
    , bInput = b__black_40
    , fgSlideInWarn = white
    , bgSlideInWarn = bg_orange
    , fgSlideInErr = white
    , bgSlideInErr = bg_red
    , fgDialog = white
    , bgDialog = bg_blue
    , bDialog = b__transparent
    , shadowSettings = shadow_5
    }


lightMainFG : String
lightMainFG =
    navy


themeLunatic : Theme
themeLunatic =
    { id = "builtInLunatic"
    , name = "Lunatic"
    , font = system_sans_serif
    , fontMono = code
    , fg = lightMainFG
    , bg = bg_washed_yellow
    , fgRemark = black_50
    , fgAlert = red
    , fgSpinner = dark_red
    , fgOpName = dark_blue
    , fgThreadSubject = purple
    , bSeparator = b__light_purple
    , fgPostNo = lightMainFG
    , fgPost = lightMainFG
    , fgPostHead = lightMainFG
    , fgPostName = dark_blue
    , fgPostTrip = purple
    , bgPost = bg_washed_red
    , bFocusedPost = b__light_red
    , fgQuote = light_red
    , fgMenu = lightMainFG
    , bgMenu = bg_purple
    , shadowMenu = ""
    , fgMenuButton = white
    , fgMenuButtonDisabled = black_20
    , fgTextButton = purple
    , fgButton = white
    , bgButton = bg_red
    , bgButtonHover = hover_bg_dark_red
    , fgButtonDisabled = black_20
    , bgButtonDisabled = bg_black_10
    , fgInput = lightMainFG
    , bgInput = bg_white
    , bInput = b__black_40
    , fgSlideInWarn = white
    , bgSlideInWarn = bg_orange
    , fgSlideInErr = white
    , bgSlideInErr = bg_red
    , fgDialog = white
    , bgDialog = bg_purple
    , bDialog = b__transparent
    , shadowSettings = shadow_5
    }
