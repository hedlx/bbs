module Update.Plugins exposing (update)

import Model exposing (Model)
import Msg exposing (Msg)
import Toasty


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.ToastyMsg msgToasty ->
            let
                ( newPlugins, cmds ) =
                    Toasty.update Toasty.config Msg.ToastyMsg msgToasty model.plugins
            in
            ( { model | plugins = newPlugins }, cmds )

        _ ->
            ( model, Cmd.none )
