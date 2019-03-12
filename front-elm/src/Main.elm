module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Commands
import Model exposing (Flags, Model)
import Msg exposing (Msg)
import Route
import Subscriptions
import Update
import Url exposing (Url)
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


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            Route.initModel flags url key
    in
    ( model, Commands.init model )
