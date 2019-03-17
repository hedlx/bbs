module Update.PostForm exposing (update)

import Commands
import Env
import File.Select as Select
import Model exposing (Model)
import Model.Page as Page
import Model.PostForm as PostForm
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.FormNameChanged newVal ->
            mapPostForm (PostForm.setName newVal) model

        Msg.FormTripChanged newVal ->
            mapPostForm (PostForm.setTrip newVal) model

        Msg.FormPassChanged newVal ->
            mapPostForm (PostForm.setPass newVal) model

        Msg.FormSubjChanged newVal ->
            mapPostForm (PostForm.setSubj newVal) model

        Msg.FormTextChanged newVal ->
            mapPostForm (PostForm.setText newVal) model

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

                Page.Thread content form ->
                    let
                        ( newForm, loadPreviewsCmd ) =
                            PostForm.addFiles selectedFiles form
                    in
                    ( { model | page = Page.Thread content newForm }, loadPreviewsCmd Msg.FormFilePreviewLoaded )

                _ ->
                    ( model, Cmd.none )

        Msg.FormFilePreviewLoaded fileID preview ->
            mapPostForm (PostForm.setFilePreview fileID preview) model

        Msg.FormRemoveFile fileID ->
            mapPostForm (PostForm.removeFile fileID) model

        Msg.FormSubmit ->
            case Page.postForm model.page of
                Just form ->
                    let
                        filesUploadCmds =
                            uploadFormFiles form

                        newPage =
                            Page.mapPostForm PostForm.disable model.page

                        cmd =
                            if List.isEmpty filesUploadCmds then
                                submitPageForm newPage

                            else
                                Cmd.batch filesUploadCmds
                    in
                    ( { model | page = newPage }, cmd )

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
                    Commands.showDefaultHttpErrorPopUp error model

                _ ->
                    ( model, Cmd.none )

        Msg.GotLimits result ->
            case result of
                Ok newLimits ->
                    mapPostForm (PostForm.setLimits newLimits) model

                Err _ ->
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


mapPostForm f model =
    ( { model | page = Page.mapPostForm f model.page }, Cmd.none )
