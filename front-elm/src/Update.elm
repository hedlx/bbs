module Update exposing (update)

import Model exposing (Model)
import Msg exposing (Msg)
import Update.Extra exposing (andThen)
import Update.Index as Index
import Update.Main as Main
import Update.Plugins as Plugins
import Update.PostForm as PostForm
import Update.ResourceCreation as ResourceCreation
import Update.Route as Route
import Update.Special as Special
import Update.Thread as Thread


update : Msg -> Model -> ( Model, Cmd Msg )
update msg =
    Main.update msg
        >> andThen (Index.update msg)
        >> andThen (Thread.update msg)
        >> andThen (Route.update msg)
        >> andThen (PostForm.update msg)
        >> andThen (ResourceCreation.update msg)
        >> andThen (Plugins.update msg)
        >> andThen (Special.update msg)
