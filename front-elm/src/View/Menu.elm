module View.Menu exposing (view)

import Html exposing (..)
import View.Icons as Icons


view style model =
    div [ style.menu ]
        [ btnIndex style
        , div [ style.flexFiller ] []
        , btnSettings style
        ]


btnIndex style =
    div [ style.iconicButtonLink ] [ Icons.hedlx ]


btnSettings style =
    div [ style.iconicButton ] [ Icons.settings ]
