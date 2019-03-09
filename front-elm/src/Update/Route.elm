module Update.Route exposing (update)

import Browser
import Browser.Navigation as Nav
import Commands
import Model.Page
import Msg
import Route
import Url


update msg model =
    case msg of
        Msg.LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    let
                        newModel =
                            { model | page = Route.route model.cfg url }
                    in
                    ( newModel, Nav.pushUrl model.cfg.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        Msg.UrlChanged url ->
            let
                newModel =
                    { model | page = Route.route model.cfg url }
            in
            ( newModel, Commands.init newModel )

        _ ->
            ( model, Cmd.none )
