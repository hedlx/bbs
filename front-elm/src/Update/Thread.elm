module Update.Thread exposing (update)

import Commands
import Model.Page as Page
import Model.PostForm as PostForm
import Msg


update msg model =
    case ( msg, model.page ) of
        ( Msg.GotThread result, Page.Thread state postForm ) ->
            case result of
                Ok thread ->
                    ( { model | page = Page.Thread (Page.Content thread) postForm }, Cmd.none )

                Err _ ->
                    Debug.todo "handle GotThread error"

        _ ->
            ( model, Cmd.none )
