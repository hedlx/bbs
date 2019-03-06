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
                div [ localStyle.postHeadElement, localStyle.threadNo ] [ text <| ("[" ++ String.fromInt threadID) ++ "]" ]

            else
                div [ localStyle.postHeadElement, localStyle.postNo ] [ text <| ("#" ++ String.fromInt post.no) ]

        trip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ localStyle.postTrip ] [ text ("!" ++ post.trip) ]

        name =
            span [ localStyle.postName ] [ text <| String.left 32 post.name ]

        nameTrip =
            div [ localStyle.postHeadElement ] [ name, trip ]

        time =
            div [ localStyle.postHeadElement ] [ Time.view post.ts ]

        postHead =
            div [ localStyle.postHead ]
                [ no
                , nameTrip
                , time
                ]

        postBody =
            div [ localStyle.postBody, Html.Attributes.style "white-space" "pre-wrap" ] [ text post.text ]
    in
    div [ style.post ]
        [ postHead, postBody ]


toOpStyle style =
    { style
        | post = style.op
        , postName = style.opName
    }
