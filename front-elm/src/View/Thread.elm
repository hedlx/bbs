module View.Thread exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Model.Thread
import View.Post as Post
import View.PostForm as PostForm


view style cfg ( thread, postForm ) =
    div [ style.content, style.thread ] <|
        [ Post.view style cfg False thread.id thread.op ]
            ++ posts style cfg thread
            ++ [ replyForm style postForm ]


posts style cfg { id, replies } =
    List.map (Html.Lazy.lazy5 Post.view style cfg False id) replies


replyForm style form =
    div [ style.replyForm ]
        [ PostForm.view style form ]
