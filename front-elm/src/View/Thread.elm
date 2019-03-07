module View.Thread exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Model.Thread
import View.Post as Post
import View.PostForm as PostForm


view style ( thread, postForm ) =
    div [ style.content, style.thread ] <|
        [ Post.view style False thread.id thread.op ]
            ++ posts style thread
            ++ [ replyForm style postForm ]


posts style { id, replies } =
    List.map (Html.Lazy.lazy4 Post.view style False id) replies


replyForm style form =
    div [ style.replyForm ]
        [ PostForm.view style form ]
