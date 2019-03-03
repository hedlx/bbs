module Subscriptions.Plugins exposing (subscriptions)

import Model exposing (Model)
import Msg exposing (Msg)
import Spinner


subscriptions model =
    Sub.batch
        [ Sub.map Msg.SpinnerMsg Spinner.subscription
        ]
