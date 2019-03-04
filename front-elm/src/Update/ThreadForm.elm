module Update.ThreadForm exposing (update)

import Commands
import Model.Page as Page
import Model.ThreadForm as ThreadForm
import Msg


update msg model =
    case ( model.page, msg ) of
        ( Page.NewThread form, Msg.FormNameChanged newVal ) ->
            ( { model | page = Page.NewThread <| ThreadForm.setName newVal form }, Cmd.none )

        ( Page.NewThread form, Msg.FormPassChanged newVal ) ->
            ( { model | page = Page.NewThread <| ThreadForm.setPass newVal form }, Cmd.none )

        ( Page.NewThread form, Msg.FormTextChanged newVal ) ->
            ( { model | page = Page.NewThread <| ThreadForm.setText newVal form }, Cmd.none )

        ( Page.NewThread form, Msg.FormSubmit ) ->
            ( model, Commands.createThread <| ThreadForm.encode form )

        _ ->
            ( model, Cmd.none )
