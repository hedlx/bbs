module Main exposing (main)

import Browser
import Commands
import Json.Encode as Encode
import Model exposing (Flags, Model)
import Msg exposing (Msg)
import Subscriptions
import Update
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }


init flags url key =
    ( Model.empty, Commands.getThreads )


onUrlRequest urlRequest =
    Msg.Empty


onUrlChange url =
    Msg.Empty
