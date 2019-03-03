module Update.Plugins exposing (update)

import Msg
import Spinner


update msg model =
    case msg of
        Msg.SpinnerMsg pluginMsg ->
            ( { model | spinner = Spinner.update pluginMsg model.spinner }, Cmd.none )

        _ ->
            ( model, Cmd.none )
