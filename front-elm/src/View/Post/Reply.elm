module View.Post.Reply exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import View.Post as Post


view style post =
    let
        postHead =
            div [ style.postHead ]
                [ no style post
                , Post.name style post
                , Post.time style post
                ]
    in
    div [ style.post ] [ postHead, Post.body style post ]


no style post =
    Post.headElement style
        [ style.postNo ]
        [ text <| ("#" ++ String.fromInt post.no) ]
