module View.Threads exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import View.ThreadPreview as ThreadPreview


view style cfg threads =
    div [ style.content, id "page-content" ] <|
        List.map (ThreadPreview.view style cfg) threads
