module Main exposing (main)

import Alert exposing (Alert)
import Browser
import Browser.Navigation as Nav
import Config exposing (Config)
import Dict
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onChange)
import Html.Extra
import Http
import Icons
import Json.Encode as Encode
import Limits exposing (Limits)
import LocalStorage
import Page exposing (Page)
import Regex
import Route
import String.Extra
import Style
import Style.Animations as Animations
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
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
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }



-- Init


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    route url
        { cfg = Config.init flags url key
        , alerts = Alert.init
        , page = Page.NotFound
        , isSettingsVisible = False
        }



-- Model


type alias Model =
    { cfg : Config
    , alerts : Alert.State
    , page : Page
    , isSettingsVisible : Bool
    }



-- Update


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageMsg Page.Msg
    | AlertMsg Alert.Msg
    | GotLimits (Result Http.Error Limits)
    | GotTimeZone Zone
    | ToggleSettings
    | ThemeSelected Theme.ID
    | UserSettingsChanged Encode.Value


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

        GotLimits (Ok newLimits) ->
            ( mapConfig (Config.setLimits newLimits) model, Cmd.none )

        GotTimeZone newZone ->
            ( mapConfig (Config.setTimeZone newZone) model, Cmd.none )

        ToggleSettings ->
            ( { model | isSettingsVisible = not model.isSettingsVisible }, Cmd.none )

        ThemeSelected newThemeID ->
            let
                newTheme =
                    Theme.selectBuiltIn newThemeID

                newCfg =
                    Config.setTheme newTheme model.cfg

                cmdSaveUserSettings =
                    LocalStorage.saveUserSettings (Config.encodeUserSettings newCfg)
            in
            ( { model | cfg = newCfg }, cmdSaveUserSettings )

        UserSettingsChanged newFlags ->
            ( mapConfig (Config.mergeFlags newFlags) model, Cmd.none )


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


mapConfig : (Config -> Config) -> Model -> Model
mapConfig f model =
    { model | cfg = f model.cfg }


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



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    LocalStorage.userSettingsChanged UserSettingsChanged



-- View


view : Model -> Browser.Document Msg
view { cfg, page, alerts, isSettingsVisible } =
    let
        pageTitle =
            Page.title page

        title =
            if String.Extra.isBlank pageTitle then
                Env.bbsName

            else
                Env.bbsName ++ " | " ++ pageTitle

        theme =
            cfg.theme

        styleBody =
            classes [ theme.fg ]
    in
    { title = title
    , body =
        [ Tachyons.tachyons.css
        , Animations.css
        , div [ styleBody ]
            [ viewMenu cfg
            , Html.Extra.viewIf isSettingsVisible (viewSettingsDialog cfg)
            , Html.map AlertMsg (Alert.view cfg.theme alerts)
            , Html.map PageMsg (Page.view cfg page)
            ]
        ]
    }


viewMenu : Config -> Html Msg
viewMenu cfg =
    let
        theme =
            cfg.theme

        style =
            classes
                [ T.fixed
                , T.pa0
                , T.fl
                , T.h_100
                , T.w3
                , T.flex
                , T.flex_column
                , T.items_center
                , theme.bgMenu
                ]
    in
    div [ style ]
        [ btnIndex theme
        , btnNewThread theme
        , btnDelete theme
        , div [ Style.flexFill ] []
        , btnSettings theme
        ]


btnIndex : Theme -> Html Msg
btnIndex theme =
    a [ href <| Route.internalLink [] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Style.buttonEnabled
            , Html.Attributes.title "Main Page"
            , class theme.fgMenuButton
            ]
            [ Icons.hedlx ]
        ]


btnNewThread : Theme -> Html Msg
btnNewThread theme =
    a [ href <| Route.internalLink [ "new" ] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Style.buttonEnabled
            , Html.Attributes.title "Start New Thread"
            , class theme.fgMenuButton
            ]
            [ Icons.add ]
        ]


btnDelete : Theme -> Html Msg
btnDelete theme =
    let
        isEnabled =
            False

        dynamicAttrs =
            if isEnabled then
                [ Style.buttonEnabled
                , Html.Attributes.title "Delete"
                , class theme.fgMenuButton
                ]

            else
                [ Html.Attributes.title "Delete\nYou need to select items before"
                , class theme.fgMenuButtonDisabled
                ]
    in
    div ([ styleButtonMenu, Style.buttonIconic ] ++ dynamicAttrs) [ Icons.delete ]


btnSettings : Theme -> Html Msg
btnSettings theme =
    div
        [ styleButtonMenu
        , Style.buttonIconic
        , Style.buttonEnabled
        , Html.Attributes.title "Settings"
        , onClick ToggleSettings
        , class theme.fgMenuButton
        ]
        [ Icons.settings ]


styleButtonMenu : Attribute Msg
styleButtonMenu =
    class T.pa3


viewSettingsDialog : Config -> Html Msg
viewSettingsDialog cfg =
    let
        theme =
            cfg.theme

        styleContainer =
            classes
                [ T.fixed
                , T.ml5
                , T.pl3
                , T.bottom_1
                , Animations.fadein_l
                ]

        style =
            classes
                [ T.w_100
                , T.pa3
                , T.br2
                , theme.fgSettings
                , theme.bgSettings
                ]
    in
    div [ styleContainer ]
        [ div [ style ]
            [ viewSettingsOption "UI Theme" [ viewSelectTheme theme ] ]
        ]


viewSettingsOption : String -> List (Html Msg) -> Html Msg
viewSettingsOption settingLabel optionBody =
    div [] (span [ class T.mr3 ] [ text settingLabel ] :: optionBody)


viewSelectTheme : Theme -> Html Msg
viewSelectTheme currentTheme =
    select [ onChange ThemeSelected ] <|
        Dict.foldr (addSelectThemeOption currentTheme.id) [] Theme.builtIn


addSelectThemeOption : Theme.ID -> Theme.ID -> Theme -> List (Html Msg) -> List (Html Msg)
addSelectThemeOption seletedID themeID theme options =
    option [ value themeID, selected (seletedID == themeID) ] [ text theme.name ] :: options
