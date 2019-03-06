module View.NotFound exposing (view)

import Html exposing (..)


view style =
    h1 [ style.content ] [ text "Page Not Found" ]
