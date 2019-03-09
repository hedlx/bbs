module Model.Theme exposing (Theme, builtIn, empty)

import Dict exposing (Dict)
import Model.Theme.Dark as Dark


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
    }


builtIn : Dict String Theme
builtIn =
    Dict.fromList
        [ ( empty.id, empty )
        ]


empty : Theme
empty =
    Dark.theme
