module Update.Plugins exposing (update)

import Msg


update msg model =
    case msg of
        _ ->
            ( model, Cmd.none )
