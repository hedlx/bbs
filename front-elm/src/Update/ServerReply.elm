module Update.ServerReply exposing (update)

import Commands
import Model.Page as Page
import Msg


update msg model =
    case msg of
        Msg.GotThreads result ->
            case result of
                Ok threads ->
                    ( { model
                        | isLoading = False
                        , threads = List.reverse threads
                      }
                    , Cmd.none
                    )

                -- TODO: handle error
                Err _ ->
                    ( model, Cmd.none )

        Msg.ThreadCreated result ->
            case result of
                Ok () ->
                    ( model, Commands.redirect "/" model )

                Err _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
