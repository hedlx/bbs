module Post.Op exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Post
import Route
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T


view toMsg cfg thread =
    let
        theme =
            cfg.theme

        op =
            thread.op

        style =
            classes [ T.mb3, T.pa2, T.br1, theme.bgPost ]
    in
    div [ style ]
        [ viewOpHead toMsg cfg thread op
        , Post.viewBody toMsg theme thread.id op
        ]


viewOpHead toMsg { theme, timeZone } thread op =
    let
        style =
            classes
                [ T.f6
                , T.overflow_hidden
                , T.pa1
                , theme.fgPostHead
                , theme.fontMono
                , theme.bgPost
                ]
    in
    div [ style ]
        [ viewNo theme thread
        , viewSubject theme thread
        , Post.viewName { theme | fgPostName = theme.fgOpName } op
        , Post.viewPostTime timeZone op
        , viewReply toMsg theme thread
        , viewShowAll theme thread
        ]


viewNo theme thread =
    viewThreadLink thread [ Post.viewButtonHead theme (String.fromInt thread.id) ]


viewReply toMsg theme thread =
    span
        [ Style.buttonEnabled theme
        , onClick <| toMsg.onReplyToClicked thread.id 0
        ]
        [ Post.viewButtonHead theme "Reply" ]


viewShowAll theme thread =
    viewThreadLink thread [ Post.viewButtonHead theme "Show All" ]


viewSubject theme thread =
    case thread.subject of
        Nothing ->
            nothing

        Just subjectText ->
            let
                style =
                    classes [ T.f4, theme.fgThreadSubject ]
            in
            viewThreadLink thread <|
                [ Post.viewHeadElement
                    [ Style.buttonEnabled theme, style ]
                    [ text subjectText ]
                ]


viewThreadLink thread =
    a [ href <| Route.internalLink [ String.fromInt thread.id ] ]
