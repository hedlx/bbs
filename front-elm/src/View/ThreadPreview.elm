module View.ThreadPreview exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Model.Thread
import View.Post as Post


view style thread =
    div [ style.threadPreview ]
        [ op style thread.op
        , repliesList style thread.replies
        ]


op style post =
    Post.view style True post


repliesList style replies =
    if List.isEmpty replies then
        nothing

    else
        div [ style.previewPosts ] <|
            List.map (Post.view style False) replies
