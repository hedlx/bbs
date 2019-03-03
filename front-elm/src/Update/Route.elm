module Update.Route exposing (update)

import Browser
import Browser.Navigation as Nav
import Msg
import Route
import Url


update msg model =
    case msg of
        Msg.LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msg.UrlChanged url ->
            ( { model | page = Route.route url }, Cmd.none )

        _ ->
            ( model, Cmd.none )
