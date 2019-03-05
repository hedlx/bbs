module View.ThreadPreview exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Model.Thread
import View.Post as Post


view style thread =
    div [ style.threadPreview ]
        [ opPost style thread
        , repliesList style thread
        ]


opPost style { id, op } =
    Post.view style True id op


repliesList style { id, replies } =
    if List.isEmpty replies then
        nothing

    else
        div [ style.previewPosts ] <|
            List.map (Post.view style False id) replies
