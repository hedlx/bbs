module Main exposing (main)

import Browser
import Commands
import Json.Encode as Encode
import Model exposing (Flags, Model)
import Msg exposing (Msg)
import Route
import Subscriptions
import Update
import Url
import View


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = Subscriptions.subscriptions
        , onUrlRequest = Msg.LinkClicked
        , onUrlChange = Msg.UrlChanged
        }


init flags url key =
    let
        model =
            Route.initModel flags url key
    in
    ( model, Commands.init model )
