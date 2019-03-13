module View.Thread exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import View.Post.Reply as Reply
import View.PostForm as PostForm


view style cfg postForm thread =
    div
        [ -- This id is required to get scrolling manipulations working
          id "page-content"
        , style.content
        , style.thread
        ]
    <|
        [ subject style thread ]
            ++ posts style cfg thread
            ++ [ replyForm style postForm ]


subject style thread =
    let
        strSubject =
            Maybe.withDefault ("Thread #" ++ String.fromInt thread.id) thread.subject
    in
    h1 [ style.threadSubjectBig ] [ text strSubject ]


posts style cfg { id, messages } =
    List.map (Html.Lazy.lazy4 Reply.view style cfg id) messages


replyForm style form =
    div [ style.replyForm ]
        [ PostForm.view style form ]
