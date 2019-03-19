module Update.Thread exposing (update)

import Commands
import Model exposing (Model)
import Model.Page as Page
import Model.PostForm as PostForm
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
                    { model | page = Page.mapPostForm PostForm.enable model.page }
                        |> Commands.showDefaultHttpErrorPopUp error

        _ ->
            ( model, Cmd.none )
