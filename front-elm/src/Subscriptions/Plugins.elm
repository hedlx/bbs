module Subscriptions.Plugins exposing (subscriptions)

import Model exposing (Model)
import Model.Page
import Msg exposing (Msg)


subscriptions model =
    Sub.batch []
