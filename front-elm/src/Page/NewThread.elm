module Page.NewThread exposing (Msg, State, init, update, view)

import Alert
import Config exposing (Config)
import File exposing (File)
import FilesDrop
import Html exposing (..)
import Html.Events exposing (..)
import Page.Response as Response exposing (Response)
import PostForm exposing (PostForm)
import Route
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T


init : ( State, Cmd Msg )
init =
    ( PostForm.enableSubj PostForm.empty
    , Cmd.none
    )



-- MODEL


type alias State =
    PostForm.PostForm


type Msg
    = NoOp
    | PostFormMsg PostForm.Msg
    | FilesDropped (List File)


path : List String
path =
    [ "threads" ]



-- UPDATE


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        NoOp ->
            Response.None

        PostFormMsg subMsg ->
            handlePostFormResponse cfg (updatePostForm cfg subMsg state)

        FilesDropped files ->
            handlePostFormResponse cfg (PostForm.addFiles cfg.limits files state)


updatePostForm : Config -> PostForm.Msg -> PostForm -> PostForm.Response
updatePostForm =
    PostForm.update path


handlePostFormResponse : Config -> PostForm.Response -> Response State Msg
handlePostFormResponse cfg postFormResp =
    case postFormResp of
        PostForm.Ok newState newCmd ->
            Response.Ok newState (Cmd.map PostFormMsg newCmd) Alert.None

        PostForm.Err alert newState ->
            Response.Ok newState Cmd.none (Alert.map PostFormMsg alert)

        PostForm.Submitted _ ->
            Response.redirect cfg Route.index



--View


view : Config -> State -> Html Msg
view cfg form =
    div
        [ Style.content
        , Style.contentNoScroll
        , FilesDrop.onDrop FilesDropped
        , FilesDrop.onDragOver NoOp
        ]
        [ div [ classes [ T.pt4, T.pr2, T.pt0_ns, T.pr0_ns ] ]
            [ Html.map PostFormMsg (PostForm.view cfg form) ]
        ]
