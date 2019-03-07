module View.Post exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Route
import Tachyons.Classes as TC
import View.Time as Time


view style cfg isOp threadID post =
    let
        localStyle =
            if isOp then
                toOpStyle style

            else
                style

        strThreadID =
            String.fromInt threadID

        threadLink =
            a [ href <| Route.link cfg.urlApp [ strThreadID ] ]

        no =
            if isOp then
                threadLink [ btnHead localStyle strThreadID ]

            else
                headElement localStyle
                    [ localStyle.postNo ]
                    [ text <| ("#" ++ String.fromInt post.no) ]

        trip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ localStyle.postTrip ] [ text ("!" ++ post.trip) ]

        name =
            span [ localStyle.postName ] [ text <| String.left 32 post.name ]

        nameTrip =
            headElement localStyle [] [ name, trip ]

        time =
            headElement localStyle [] [ Time.view post.ts ]

        reply =
            if isOp then
                threadLink [ btnHead localStyle "Reply" ]

            else
                nothing

        postHead =
            div [ localStyle.postHead ]
                [ no
                , nameTrip
                , time
                , reply
                ]

        postBody =
            div
                [ localStyle.postBody
                , Html.Attributes.style "white-space" "pre-line"
                , Html.Attributes.style "word-wrap" "break-word"
                ]
                [ text post.text ]
    in
    div [ style.post ]
        [ postHead, postBody ]


headElement style attrs =
    div <| [ style.postHeadElement ] ++ attrs


btnHead style btnText =
    headElement style
        []
        [ span [ style.fgButton ] [ text "[" ]
        , span [ style.hypertextLink ] [ text btnText ]
        , span [ style.fgButton ] [ text "]" ]
        ]


toOpStyle style =
    { style
        | post = style.op
        , postName = style.opName
    }
