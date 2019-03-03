module View.Threads exposing (view)

import Html exposing (..)
import View.ThreadPreview as ThreadPreview


view style threads =
    div [ style.threads ] <|
        List.map (ThreadPreview.view style) threads
