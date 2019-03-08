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
        , btnDelete style model
        , div [ style.flexFiller ] []
        , btnSettings style model
        ]


btnIndex style { cfg } =
    a [ href <| Route.internalLink [] ]
        [ div [ style.menuButton, style.buttonEnabled, title "Main Page" ] [ Icons.hedlx ] ]


btnNewThread style { cfg } =
    a [ href <| Route.internalLink [ "new" ] ]
        [ div [ style.menuButton, style.buttonEnabled, title "Start New Thread" ] [ Icons.add ] ]


btnDelete style model =
    let
        -- TODO
        isEnabled =
            False

        dynamicAttrs =
            if isEnabled then
                [ style.buttonEnabled, title "Delete" ]

            else
                [ style.buttonDisabled, title "Delete\nYou need to select items before" ]
    in
    div ([ style.menuButton, style.buttonDisabled ] ++ dynamicAttrs) [ Icons.delete ]


btnSettings style { cfg } =
    div [ style.menuButton, style.buttonEnabled, title "Settings" ] [ Icons.settings ]
