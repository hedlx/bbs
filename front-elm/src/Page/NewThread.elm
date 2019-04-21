module Page.NewThread exposing (Msg, State, init, update, view)

import Html exposing (..)
import Html.Events exposing (..)
import Page.Response as Response
import PostForm
import Style



-- Model


type alias State =
    PostForm.PostForm


type Msg
    = PostFormMsg PostForm.Msg


init cfg =
    ( PostForm.setSubj cfg.limits "" PostForm.init
    , Cmd.none
    )


path =
    [ "threads" ]



-- Update


update cfg msg state =
    case msg of
        PostFormMsg subMsg ->
            case updatePostForm cfg.limits subMsg state of
                PostForm.Ok newState newCmd ->
                    Response.Ok newState (Cmd.map PostFormMsg newCmd)

                PostForm.Err alert newState ->
                    Response.Failed alert newState Cmd.none

                PostForm.Submitted _ ->
                    Response.Redirect []


updatePostForm =
    PostForm.update path



--View


view cfg form =
    div [ Style.content, Style.contentNoScroll ]
        [ Html.map PostFormMsg (PostForm.view cfg.theme cfg.limits form) ]
