module View.Post exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)


view style isOp post =
    let
        localStyle =
            if isOp then
                toOpStyle style

            else
                style

        trip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ localStyle.postTrip ] [ text (" [" ++ post.trip ++ "] ") ]

        postHead =
            div [ localStyle.postHead ]
                [ span [ localStyle.postName ] [ text post.name ]
                , trip
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
        , postTrip = style.opTrip
        , postHead = style.opHead
        , postBody = style.opBody
    }
