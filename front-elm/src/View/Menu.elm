module View.Menu exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Msg
import Route
import View.Icons as Icons


view style model =
    div [ style.menu ]
        [ btnIndex style model
        , btnNewThread style model
        , div [ style.flexFiller ] []
        , btnSettings style model
        ]


btnIndex style { cfg } =
    a [ href <| Route.link cfg.urlApp [] ]
        [ div [ style.iconicButton, style.menuButton, title "Main Page" ] [ Icons.hedlx ] ]


btnNewThread style { cfg } =
    a [ href <| Route.link cfg.urlApp [ "new" ] ]
        [ div [ style.iconicButton, style.menuButton, title "Create Thread" ] [ Icons.add ] ]


btnSettings style { cfg } =
    div [ style.iconicButton, style.menuButton, title "Settings" ] [ Icons.settings ]
