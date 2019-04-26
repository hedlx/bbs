module Page.NewThread exposing (Msg, State, init, update, view)

import Config exposing (Config)
import Html exposing (..)
import Html.Events exposing (..)
import Page.Response as Response exposing (Response)
import PostForm exposing (PostForm)
import Style


init : ( State, Cmd Msg )
init =
    ( PostForm.enableSubj PostForm.empty
    , Cmd.none
    )



-- Model


type alias State =
    PostForm.PostForm


type Msg
    = PostFormMsg PostForm.Msg


path : List String
path =
    [ "threads" ]



-- Update


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        PostFormMsg subMsg ->
            case updatePostForm cfg subMsg state of
                PostForm.Ok newState newCmd ->
                    Response.Ok newState (Cmd.map PostFormMsg newCmd)

                PostForm.Err alert newState ->
                    Response.Failed alert newState Cmd.none

                PostForm.Submitted _ ->
                    Response.Redirect []


updatePostForm : Config -> PostForm.Msg -> PostForm -> PostForm.Response
updatePostForm =
    PostForm.update path



--View


view : Config -> State -> Html Msg
view cfg form =
    div [ Style.content, Style.contentNoScroll ]
        [ Html.map PostFormMsg (PostForm.view cfg form) ]
