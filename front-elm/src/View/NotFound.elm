module View.NotFound exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Tachyons exposing (classes)
import Tachyons.Classes as TC


view style =
    h1 [ style.content, classes [TC.flex, TC.flex_column, TC.justify_center] ]
        [ div [ style.notFound ] [ text "Page Not Found" ] ]
