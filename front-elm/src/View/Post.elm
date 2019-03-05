module View.Post exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Tachyons.Classes as TC
import View.Time as Time


view style isOp threadID post =
    let
        localStyle =
            if isOp then
                toOpStyle style

            else
                style

        no =
            if isOp then
                span [ localStyle.postHeadElement, localStyle.threadNo ] [ text <| ("[" ++ String.fromInt threadID) ++ "]" ]

            else
                span [ localStyle.postHeadElement, localStyle.postNo ] [ text <| ("#" ++ String.fromInt post.no) ]

        trip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ localStyle.postTrip ] [ text ("(" ++ post.trip ++ ")") ]

        name =
            span [ localStyle.postHeadElement ] [ span [ localStyle.postName ] [ text post.name ], trip ]

        time =
            span [ localStyle.postHeadElement ] [ Time.view (1000 * post.ts) ]

        postHead =
            div [ localStyle.postHead ]
                [ no
                , name
                , time
                ]

        postBody =
            div [ localStyle.postBody ] [ text post.text ]
    in
    div [ style.post ]
        [ postHead, postBody ]


toOpStyle style =
    { style
        | post = style.op
        , postName = style.opName
    }
