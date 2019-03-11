module Update exposing (update)

import Msg
import Update.Extra exposing (andThen)
import Update.Main as Main
import Update.Plugins as Plugins
import Update.PostForm as PostForm
import Update.PostProcess as PostProcess
import Update.Route as Route
import Update.Thread as Thread
import Update.Threads as Threads


update msg =
    Main.update msg
        >> andThen (Threads.update msg)
        >> andThen (Thread.update msg)
        >> andThen (Route.update msg)
        >> andThen (PostForm.update msg)
        >> andThen (Plugins.update msg)
        >> andThen (PostProcess.update msg)
