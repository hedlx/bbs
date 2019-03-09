module View.Thread exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Model.Thread
import View.Post.Reply as Reply
import View.PostForm as PostForm


view style ( thread, postForm ) =
    div
        [ -- This id is required to get scrolling manipulations working
          id "page-content"
        , style.content
        , style.thread
        ]
    <|
        [ Reply.view style thread.op ]
            ++ posts style thread
            ++ [ replyForm style postForm ]


posts style { id, replies } =
    List.map (Html.Lazy.lazy2 Reply.view style) replies


replyForm style form =
    div [ style.replyForm ]
        [ PostForm.view style form ]
