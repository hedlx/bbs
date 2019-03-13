module View.Post.Reply exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Msg
import View.Post as Post


view style cfg threadID post =
    let
        postHead =
            div [ style.postHead ]
                [ no style threadID post
                , Post.name style post
                , Post.time style cfg.timeZone post
                ]
    in
    div [ style.post ] [ postHead, Post.body style post ]


no style threadID post =
    Post.headElement style
        [ style.postNo, style.buttonEnabled, onClick <| Msg.ReplyTo threadID post.no ]
        [ text ("#" ++ String.fromInt post.no) ]
