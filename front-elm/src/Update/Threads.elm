module Update.Threads exposing (update)

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
                    ( { model | page = newPage }, Commands.scrollPageToTop )

                Err _ ->
                    Debug.todo "handle GotThreads error"

        _ ->
            ( model, Cmd.none )