module Post.Reply exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Post
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T


view toMsg cfg threadID post =
    let
        theme =
            cfg.theme

        style =
            classes [ T.mb3, T.pa2, T.br1, theme.bgPost ]
    in
    div [ style ]
        [ viewPostHead toMsg cfg threadID post
        , Post.viewBody toMsg theme threadID post
        ]


viewPostHead toMsg { theme, timeZone } threadID post =
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
        [ viewNo toMsg theme threadID post
        , Post.viewName theme post
        , Post.viewPostTime timeZone post
        ]


viewNo toMsg theme threadID post =
    Post.viewHeadElement
        [ class theme.fgPostNo
        , Style.buttonEnabled theme
        , onClick <| toMsg.onReplyToClicked threadID post.no
        ]
        [ text ("#" ++ String.fromInt post.no) ]
