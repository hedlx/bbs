module Update.Route exposing (update)

import Browser
import Browser.Navigation as Nav
import Commands
import Model exposing (Model)
import Msg exposing (Msg)
import Regex
import Route
import Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg.LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if isShouldHandle model.cfg url then
                        ( Route.route url model, Nav.pushUrl model.cfg.key (Url.toString url) )

                    else
                        ( model, Cmd.none )

                Browser.External _ ->
                    ( model, Cmd.none )

        Msg.UrlChanged url ->
            let
                newModel =
                    Route.route url model
            in
            ( newModel, Commands.init newModel )

        _ ->
            ( model, Cmd.none )


isShouldHandle cfg url =
    let
        regexUrlApp =
            Regex.fromString ("^/?" ++ cfg.urlApp.path)
                |> Maybe.withDefault Regex.never
    in
    Regex.contains regexUrlApp url.path
