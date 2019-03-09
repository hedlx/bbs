module View.Spinner exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tachyons
import Tachyons.Classes as TC
import View.Icons


view style =
    div [ style.content, style.spinner, Tachyons.classes [ TC.flex, TC.justify_center ] ]
        [ div [ Tachyons.classes [ TC.flex, TC.justify_center, TC.flex_column ] ]
            [ View.Icons.spinner ]
        ]
