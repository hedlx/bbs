module View.Thread exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Model.Thread
import View.Post as Post


view style thread =
    div [ style.content, style.thread ] <|
        [ Post.view style False thread.id thread.op ]
            ++ posts style thread


posts style { id, replies } =
    List.map (Post.view style False id) replies
