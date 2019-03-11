module View.Thread exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Model.Thread
import View.Post.Reply as Reply
import View.PostForm as PostForm


view style postForm thread =
    div
        [ -- This id is required to get scrolling manipulations working
          id "page-content"
        , style.content
        , style.thread
        ]
    <|
        [ subject style thread
        , Reply.view style thread.id thread.op
        ]
            ++ posts style thread
            ++ [ replyForm style postForm ]


subject style thread =
    thread.subject
        |> Maybe.map (\subj -> h1 [ style.threadSubject ] [ text subj ])
        >> Maybe.withDefault nothing


posts style { id, replies } =
    List.map (Html.Lazy.lazy3 Reply.view style id) replies


replyForm style form =
    div [ style.replyForm ]
        [ PostForm.view style form ]
