module Update exposing (update)

import Msg
import Update.Extra exposing (andThen)
import Update.Plugins as Plugins


update msg =
    mainUpdate msg
        >> andThen (Plugins.update msg)


mainUpdate msg model =
    case msg of
        Msg.GotThreads result ->
            case result of
                Ok threads ->
                    ( { model
                        | isLoading = False
                        , threads = threads
                      }
                    , Cmd.none
                    )

                -- TODO: handle error
                Err _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
