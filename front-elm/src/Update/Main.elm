module Update.Main exposing (update)

import Commands
import Model exposing (Model)
import Model.PopUp
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.GotTimeZone zone ->
            let
                cfg =
                    model.cfg

                newCfg =
                    { cfg | timeZone = Just zone }
            in
            ( { model | cfg = newCfg }, Cmd.none )

        Msg.GotLimits result ->
            case result of
                Ok limits ->
                    let
                        cfg =
                            model.cfg

                        newCfg =
                            { cfg | limits = limits }
                    in
                    ( { model | cfg = newCfg }, Cmd.none )

                Err _ ->
                    Commands.showPopUp
                        (Model.PopUp.Warning
                            """
                            Failed to get metadata from the server. 
                            App functionality can be restricted. 
                            Please, check your Internet connection and reload the page.
                            """
                        )
                        model

        Msg.ThreadCreated result ->
            case result of
                Ok () ->
                    ( model, Commands.redirect [] model )

                Err error ->
                    Commands.showDefaultHttpErrorPopUp error model

        _ ->
            ( model, Cmd.none )
