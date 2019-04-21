module Spinner exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Icons
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as TC
import Theme exposing (Theme)


view : Theme -> Float -> Html msg
view theme spinnerSize =
    div
        [ Style.content
        , classes [ theme.fgSpinner, TC.flex, TC.justify_center ]
        ]
        [ div
            [ classes [ TC.flex, TC.justify_center, TC.flex_column ] ]
            [ Icons.spinner spinnerSize ]
        ]
