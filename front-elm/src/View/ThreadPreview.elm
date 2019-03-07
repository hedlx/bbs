module View.ThreadPreview exposing (view)

import Html exposing (..)
import Html.Extra exposing (..)
import Model.Thread
import View.Post as Post


view style cfg thread =
    div [ style.threadPreview ]
        [ opPost style cfg thread
        , repliesList style cfg thread
        ]


opPost style cfg { id, op } =
    Post.view style cfg True id op


repliesList style cfg { id, replies } =
    if List.isEmpty replies then
        nothing

    else
        div [ style.previewPosts ] <|
            List.map (Post.view style cfg False id) replies
