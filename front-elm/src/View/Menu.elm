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
        [ div [ style.iconicButton, style.menuButton, title "Main Page" ] [ Icons.hedlx ] ]


btnNewThread style =
    a [ href "/new" ]
        [ div [ style.iconicButton, style.menuButton, title "Create Thread" ] [ Icons.add ] ]


btnSettings style =
    div [ style.iconicButton, style.menuButton, title "Settings" ] [ Icons.settings ]
