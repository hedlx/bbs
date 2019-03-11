module View.ThreadPreview exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Model.Thread
import View.Post.Op as Op
import View.Post.Reply as Reply


view style thread =
    div [ style.threadPreview ]
        [ Op.view style thread
        , repliesList style thread
        ]


repliesList style { id, replies } =
    if List.isEmpty replies then
        nothing

    else
        div [ style.previewPosts ] <|
            List.map (Reply.view style id) replies
