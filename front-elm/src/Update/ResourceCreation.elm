module Update.ResourceCreation exposing (update)

import Commands
import Model.Page as Page
import Model.PostForm as PostForm
import Msg


update msg model =
    case msg of
        Msg.FormSubmit ->
            case Page.postForm model.page of
                Just form ->
                    let
                        filesUploadCmds =
                            uploadFormFiles form

                        cmd =
                            if List.isEmpty filesUploadCmds then
                                submitPageForm model.page

                            else
                                Cmd.batch filesUploadCmds
                    in
                    ( model, cmd )

                Nothing ->
                    ( model, Cmd.none )

        Msg.FormFileUploaded result ->
            case ( Page.postForm model.page, result ) of
                ( Just form, Ok ( fileID, backendID ) ) ->
                    let
                        newForm =
                            PostForm.setFileBackendID fileID backendID form

                        newPage =
                            Page.mapPostForm (\_ -> newForm) model.page

                        cmd =
                            if List.isEmpty (PostForm.notUploadedFiles newForm) then
                                submitPageForm newPage

                            else
                                Cmd.none
                    in
                    ( { model | page = newPage }, cmd )

                ( _, Err error ) ->
                    { model | page = Page.mapPostForm PostForm.enable model.page }
                        |> Commands.showDefaultHttpErrorPopUp error

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


uploadFormFiles form =
    PostForm.notUploadedFiles form
        |> List.map uploadFile


uploadFile rec =
    let
        toMsg =
            Msg.FormFileUploaded << Result.map (\backendID -> ( rec.id, backendID ))
    in
    Commands.uploadFile toMsg rec.file


submitPageForm page =
    case page of
        Page.NewThread form ->
            Commands.createThread <| PostForm.toRequestBody form

        Page.Thread (Page.Content thread) form ->
            Commands.createPost thread.id <| PostForm.toRequestBody form

        _ ->
            Cmd.none
