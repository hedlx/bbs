module Update.PostForm exposing (update)

import Commands
import Model.Page as Page
import Model.PostForm as PostForm
import Msg


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

        Msg.FormSubmit ->
            case model.page of
                Page.NewThread form ->
                    ( model, Commands.createThread <| PostForm.encode form )

                Page.Thread (Page.Content ( thread, form )) ->
                    ( model, Commands.createPost thread.id <| PostForm.encode form )

                _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )


updateForm f model =
    ( { model | page = Page.mapPostForm f model.page }, Cmd.none )
