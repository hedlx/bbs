module View.Post exposing
    ( body
    , btnHead
    , headElement
    , name
    , time
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Route
import Tachyons.Classes as TC
import View.Time as Time


name style post =
    let
        htmlTrip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ style.postTrip ] [ text ("!" ++ post.trip) ]

        htmlName =
            span [ style.postName ] [ text <| String.left 32 post.name ]
    in
    headElement style [] [ htmlName, htmlTrip ]


time style post =
    headElement style [] [ Time.view post.ts ]


body style post =
    div
        [ style.postBody
        , Html.Attributes.style "white-space" "pre-line"
        , Html.Attributes.style "word-wrap" "break-word"
        ]
        [ text post.text ]


headElement style attrs =
    div <| [ style.postHeadElement ] ++ attrs


btnHead style btnText =
    headElement style
        []
        [ span [ style.fgButton ] [ text "[" ]
        , span [ style.hypertextLink ] [ text btnText ]
        , span [ style.fgButton ] [ text "]" ]
        ]
