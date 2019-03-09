module Update.PostForm exposing (update)

import Commands
import Env
import File
import File.Select as Select
import Model.Page as Page
import Model.PostForm as PostForm
import Msg
import Task


update msg model =
    case msg of
        Msg.FormNameChanged newVal ->
            updateForm (PostForm.setName newVal) model

        Msg.FormTripChanged newVal ->
            updateForm (PostForm.setTrip newVal) model

        Msg.FormPassChanged newVal ->
            updateForm (PostForm.setPass newVal) model

        Msg.FormSubjChanged newVal ->
            updateForm (PostForm.setSubj newVal) model

        Msg.FormTextChanged newVal ->
            updateForm (PostForm.setText newVal) model

        Msg.FormSelectFiles ->
            ( model, Select.files Env.fileFormats Msg.FormFilesSelected )

        Msg.FormFilesSelected file moreFiles ->
            let
                selectedFiles =
                    file :: moreFiles
            in
            case model.page of
                Page.NewThread form ->
                    let
                        ( newForm, loadPreviewsCmd ) =
                            PostForm.addFiles selectedFiles form
                    in
                    ( { model | page = Page.NewThread newForm }, loadPreviewsCmd Msg.FormFilePreviewLoaded )

                Page.Thread (Page.Content ( thread, form )) ->
                    let
                        ( newForm, loadPreviewsCmd ) =
                            PostForm.addFiles selectedFiles form

                        newContent =
                            Page.Content ( thread, newForm )
                    in
                    ( { model | page = Page.Thread newContent }, loadPreviewsCmd Msg.FormFilePreviewLoaded )

                _ ->
                    ( model, Cmd.none )

        Msg.FormFilePreviewLoaded fileID preview ->
            updateForm (PostForm.setFilePreview fileID preview) model

        Msg.FormRemoveFile fileID ->
            updateForm (PostForm.removeFile fileID) model

        Msg.FormSubmit ->
            case model.page of
                Page.NewThread form ->
                    ( model, Commands.createThread <| PostForm.encode form )

                Page.Thread (Page.Content ( thread, form )) ->
                    ( model, Commands.createPost thread.id <| PostForm.encode form )

                _ ->
                    ( model, Cmd.none )

        Msg.GotLimits result ->
            case result of
                Err _ ->
                    ( model, Cmd.none )

                Ok newLimits ->
                    updateForm (PostForm.setLimits newLimits) model

        _ ->
            ( model, Cmd.none )


updateForm f model =
    ( { model | page = Page.mapPostForm f model.page }, Cmd.none )
