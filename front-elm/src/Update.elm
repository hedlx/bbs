module Update exposing (update)

import Msg
import Update.Extra exposing (andThen)
import Update.Plugins as Plugins
import Update.Route as Route
import Update.ServerReply as ServerReply
import Update.PostForm as PostForm


update msg =
    mainUpdate msg
        >> andThen (ServerReply.update msg)
        >> andThen (Route.update msg)
        >> andThen (PostForm.update msg)
        >> andThen (Plugins.update msg)


mainUpdate msg model =
    ( model, Cmd.none )
