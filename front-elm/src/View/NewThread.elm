module View.NewThread exposing (view)

import Html exposing (..)
import View.PostForm as PostForm


view style form =
    div [ style.content ]
        [ PostForm.view style form ]
