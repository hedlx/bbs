module Subscriptions exposing (subscriptions)

import Model exposing (Model)
import Msg exposing (Msg)
import Subscriptions.Plugins as Plugins


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Plugins.subscriptions model
        ]
