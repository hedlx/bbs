module Update.Thread exposing (update)

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

        Msg.GotThread result ->
            case result of
                Ok thread ->
                    ( { model | page = Page.mapThread (updateThread model.cfg thread) model.page }, Commands.scrollPageToTop )

                Err _ ->
                    Debug.todo "handle GotThread error"

        _ ->
            ( model, Cmd.none )


updateThread cfg thread state =
    case state of
        Page.Loading _ ->
            Page.Content ( thread, PostForm.empty |> PostForm.setLimits cfg.limits )

        Page.Content ( _, postForm ) ->
            Page.Content ( thread, postForm )
