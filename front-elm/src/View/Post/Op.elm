module View.Post.Op exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Route
import View.Post as Post


view style thread =
    let
        op =
            thread.op

        opHead =
            div [ style.postHead ]
                [ no style thread
                , subject style thread
                , Post.name { style | postName = style.opName } op
                , Post.time style op
                , reply style thread
                ]
    in
    div [ style.post ] [ opHead, Post.body style op ]


no style thread =
    threadLink thread [ Post.btnHead style (String.fromInt thread.id) ]


reply style thread =
    threadLink thread [ Post.btnHead style "Reply" ]


subject style thread =
    case thread.subject of
        Nothing ->
            nothing

        Just subjectText ->
            threadLink thread <|
                [ Post.headElement style
                    [ style.buttonEnabled, style.threadSubject ]
                    [ text subjectText ]
                ]


threadLink thread =
    a [ href <| Route.internalLink [ String.fromInt thread.id ] ]
