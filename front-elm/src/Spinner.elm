module Spinner exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Icons
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)


view : Theme -> Float -> Html msg
view theme spinnerSize =
    div
        [ Style.content
        , classes [ theme.fgSpinner, T.flex, T.justify_center ]
        ]
        [ div
            [ classes [ T.flex, T.justify_center, T.flex_column ] ]
            [ Icons.spinner spinnerSize ]
        ]
