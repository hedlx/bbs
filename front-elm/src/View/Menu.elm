module View.Menu exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg
import View.Icons as Icons


view style model =
    div [ style.menu ]
        [ btnIndex style
        , btnNewThread style
        , div [ style.flexFiller ] []
        , btnSettings style
        ]


btnIndex style =
    a [ href "/" ]
        [ div [ style.iconicButtonLink, title "Return the Main Page" ] [ Icons.hedlx ] ]


btnNewThread style =
    a [ href "new" ]
        [ div [ style.iconicButton, title "Create Thread" ] [ Icons.add ] ]


btnSettings style =
    div [ style.iconicButton, title "Settings" ] [ Icons.settings ]
