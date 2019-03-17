module Update.Threads exposing (update)

import Commands
import Model exposing (Model)
import Model.Page as Page
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.GotThreads result ->
            case result of
                Ok threads ->
                    let
                        newPage =
                            Page.mapIndex (\_ -> Page.Content <| List.reverse threads) model.page
                    in
                    ( { model | page = newPage }, Cmd.none )

                Err error ->
                    Commands.showDefaultHttpErrorPopUp error model

        _ ->
            ( model, Cmd.none )
