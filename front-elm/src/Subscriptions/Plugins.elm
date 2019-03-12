module Subscriptions.Plugins exposing (subscriptions)

import Model exposing (Model)
import Msg exposing (Msg)


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch []
