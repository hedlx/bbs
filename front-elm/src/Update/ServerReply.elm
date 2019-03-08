module Update.ServerReply exposing (update)

import Commands
import Model.Page as Page
import Model.PostForm as PostForm
import Msg


update msg model =
    case msg of
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
                    ( { model | page = Page.mapThread (updateThread thread) model.page }, Cmd.none )

                Err _ ->
                    Debug.todo "handle GotThread error"

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


updateThread thread state =
    case state of
        Page.Loading _ ->
            Page.Content ( thread, PostForm.empty )

        Page.Content ( _, postForm ) ->
            Page.Content ( thread, postForm )
