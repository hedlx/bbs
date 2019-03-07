module View.Threads exposing (view)

import Html exposing (..)
import View.ThreadPreview as ThreadPreview


view style cfg threads =
    div [ style.content ] <|
        List.map (ThreadPreview.view style cfg) threads
