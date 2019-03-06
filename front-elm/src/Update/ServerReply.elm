module Update.ServerReply exposing (update)

import Commands
import Model.Page as Page
import Msg


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

                Err _ ->
                    Debug.todo "handle GotThreads error"

        Msg.GotThread result ->
            case result of
                Ok thread ->
                    let
                        newPage =
                            Page.mapThread (\_ -> Page.Content thread) model.page
                    in
                    ( { model | page = newPage }, Cmd.none )

                Err _ ->
                    Debug.todo "handle GotThread error"

        Msg.ThreadCreated result ->
            case result of
                Ok () ->
                    ( model, Commands.redirect "/" model )

                Err _ ->
                    ( model, Cmd.none )

        _ ->
            ( model, Cmd.none )
