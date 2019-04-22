module Main exposing (main)

import Alert exposing (Alert)
import Browser
import Browser.Navigation as Nav
import Config exposing (Config)
import Env
import Html exposing (..)
import Http
import Json.Encode as Encode
import Limits exposing (Limits)
import Page exposing (Page)
import Regex
import String.Extra
import Style.Animations as Animations
import Tachyons
import Time exposing (Zone)
import Update.Extra
import Url exposing (Url)


type alias Flags =
    Encode.Value


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init _ url key =
    route url
        { cfg = Config.init url key
        , alerts = Alert.init
        , page = Page.NotFound
        }



-- Model


type alias Model =
    { cfg : Config
    , alerts : Alert.State
    , page : Page
    }



-- Update


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageMsg Page.Msg
    | AlertMsg Alert.Msg
    | GotLimits (Result Http.Error Limits)
    | GotTimeZone Zone


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PageMsg subMsg ->
            updatePage (Page.update model.cfg subMsg model.page) model

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    if isShouldHandleUrl model.cfg url then
                        ( model, Nav.pushUrl model.cfg.key (Url.toString url) )

                    else
                        ( model, Cmd.none )

                Browser.External _ ->
                    ( model, Cmd.none )

        UrlChanged url ->
            route url model

        AlertMsg subMsg ->
            let
                ( newAlerts, cmd ) =
                    Alert.update subMsg model.alerts
            in
            ( { model | alerts = newAlerts }, Cmd.map AlertMsg cmd )

        GotLimits (Ok newLimits) ->
            ( { model | cfg = Config.setLimits newLimits model.cfg }, Cmd.none )

        GotLimits (Err _) ->
            let
                alert =
                    Alert.Warning """
                        Failed to get metadata from the server. 
                        App functionality can be restricted. 
                        Please, check your Internet connection and reload the page.
                    """
            in
            Alert.add AlertMsg alert model.alerts
                |> Update.Extra.map (\newAlerts -> { model | alerts = newAlerts })

        GotTimeZone newZone ->
            ( { model | cfg = Config.setTimeZone newZone model.cfg }, Cmd.none )


updatePage : ( Page, Cmd Page.Msg, List Alert ) -> Model -> ( Model, Cmd Msg )
updatePage ( newPage, pageCmd, pageAlerts ) model =
    let
        alertAdders =
            List.map (Alert.add AlertMsg) pageAlerts

        addPageAlerts =
            List.foldl Update.Extra.compose Update.Extra.return alertAdders

        ( newAlerts, cmdsAlerts ) =
            addPageAlerts model.alerts

        pageCmdMapped =
            Cmd.map PageMsg pageCmd
    in
    ( { model | page = newPage, alerts = newAlerts }, Cmd.batch [ pageCmdMapped, cmdsAlerts ] )


isShouldHandleUrl : Config -> Url -> Bool
isShouldHandleUrl cfg url =
    let
        regexUrlApp =
            Regex.fromString ("^/?" ++ cfg.urlApp.path)
                |> Maybe.withDefault Regex.never
    in
    Regex.contains regexUrlApp url.path


route : Url -> Model -> ( Model, Cmd Msg )
route url model =
    let
        cmdFetchConfig =
            Config.fetch
                { onGotTimeZone = GotTimeZone
                , onGotLimits = GotLimits
                }
                model.cfg

        fromPage ( page, cmdPage ) =
            ( { model | page = page }
            , Cmd.batch
                [ cmdFetchConfig
                , Cmd.map PageMsg cmdPage
                ]
            )
    in
    replacePathWithFragment url
        |> Page.route model.cfg model.page
        >> fromPage


replacePathWithFragment : Url -> Url
replacePathWithFragment url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Just ""
    }



-- View


view : Model -> Browser.Document Msg
view { cfg, page, alerts } =
    let
        pageTitle =
            Page.title page

        title =
            if String.Extra.isBlank pageTitle then
                Env.bbsName

            else
                Env.bbsName ++ " | " ++ pageTitle
    in
    { title = title
    , body =
        [ Tachyons.tachyons.css
        , Animations.css
        , Html.map AlertMsg (Alert.view cfg.theme alerts)
        , Html.map PageMsg (Page.view cfg page)
        ]
    }
