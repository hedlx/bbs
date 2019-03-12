module View.ThreadPreview exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import View.Post.Op as Op
import View.Post.Reply as Reply


view style threadPreview =
    div [ style.threadPreview ]
        [ Op.view style threadPreview
        , viewLast style threadPreview
        ]


viewLast style { id, last } =
    if List.isEmpty last then
        nothing

    else
        div [ style.previewPosts ] <|
            List.map (Reply.view style id) last
