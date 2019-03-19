module Update.Thread exposing (update)

import Commands
import Model exposing (Model)
import Model.Media as Media
import Model.Page as Page
import Model.Post as Post
import Model.PostForm as PostForm
import Model.Thread as Thread
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( Msg.GotThread result, Page.Thread _ postForm ) ->
            case result of
                Ok thread ->
                    ( { model | page = Page.Thread (Page.Content thread) postForm }, Cmd.none )

                Err error ->
                    Commands.showDefaultHttpErrorPopUp error model

        ( Msg.PostCreated threadID result, Page.Thread pageState postForm ) ->
            case result of
                Ok () ->
                    ( { model | page = Page.Thread pageState (PostForm.init model.cfg.limits) }, Commands.getThread threadID )

                Err error ->
                    { model | page = Page.Thread pageState <| PostForm.enable postForm }
                        |> Commands.showDefaultHttpErrorPopUp error

        ( Msg.PostMediaClicked threadID postNo mediaID, Page.Thread (Page.Content thread) postForm ) ->
            let
                newThread =
                    if threadID == thread.id then
                        Thread.mapMessages postNo (Post.mapMedia mediaID Media.togglePreview) thread

                    else
                        thread
            in
            ( { model | page = Page.Thread (Page.Content newThread) postForm }, Cmd.none )

        _ ->
            ( model, Cmd.none )
