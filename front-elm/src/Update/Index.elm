module Update.Index exposing (update)

import Commands
import Model exposing (Model)
import Model.Page as Page
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( Msg.GotThreads result, Page.Index _ ) ->
            case result of
                Ok threads ->
                    ( { model | page = Page.Index << Page.Content <| List.reverse threads }, Cmd.none )

                Err error ->
                    Commands.showDefaultHttpErrorPopUp error model

        _ ->
            ( model, Cmd.none )
