module Update.Thread exposing (update)

import Model exposing (Model)
import Model.Page as Page
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( Msg.GotThread result, Page.Thread _ postForm ) ->
            case result of
                Ok thread ->
                    ( { model | page = Page.Thread (Page.Content thread) postForm }, Cmd.none )

                Err _ ->
                    Debug.todo "handle GotThread error"

        _ ->
            ( model, Cmd.none )
