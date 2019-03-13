module Update.Main exposing (update)

import Commands
import Model exposing (Model)
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
                    Debug.todo "handle GotLimits error"

        Msg.ThreadCreated result ->
            case result of
                Ok () ->
                    ( model, Commands.redirect [] model )

                Err _ ->
                    Debug.todo "handle ThreadCreated error"

        Msg.PostCreated threadID result ->
            case result of
                Ok () ->
                    ( model, Commands.redirect [ String.fromInt threadID ] model )

                Err _ ->
                    Debug.todo "handle PostCreated error"

        _ ->
            ( model, Cmd.none )
