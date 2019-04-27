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
    | SettingsStorageChanged Encode.Value
    | SettingsThemeChanged Theme.ID
    | SettingsNameChanged String
    | SettingsTripChanged String
    | SettingsPassChanged String
    | SettingsReset


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

        SettingsThemeChanged newThemeID ->
            let
                newTheme =
                    Theme.selectBuiltIn newThemeID

                newCfg =
                    Config.setTheme newTheme model.cfg
            in
            ( { model | cfg = newCfg }, saveUserSettings newCfg )

        SettingsStorageChanged newFlags ->
            ( mapConfig (Config.mergeFlags newFlags) model, Cmd.none )

        SettingsNameChanged newName ->
            updateUserSettings (Config.setName newName) model

        SettingsTripChanged newTrip ->
            updateUserSettings (Config.setTrip newTrip) model

        SettingsPassChanged newPass ->
            updateUserSettings (Config.setPass newPass) model

        SettingsReset ->
            ( mapConfig Config.resetUserSettings model, LocalStorage.cleanUserSettings () )


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


updateUserSettings : (Config -> Config) -> Model -> ( Model, Cmd Msg )
updateUserSettings f model =
    let
        newCfg =
            f model.cfg
    in
    ( { model | cfg = newCfg }, saveUserSettings newCfg )


saveUserSettings : Config -> Cmd Msg
saveUserSettings cfg =
    LocalStorage.saveUserSettings (Config.encodeUserSettings cfg)


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
        |> Page.route model.page
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
    LocalStorage.userSettingsChanged SettingsStorageChanged



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
            classes [ theme.fg, theme.font ]
    in
    { title = title
    , body =
        [ Tachyons.tachyons.css
        , Animations.css
        , main_ [ styleBody ]
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
                , T.w3_ns
                , T.h_100_ns
                , T.w_100
                , T.flex
                , T.flex_column_ns
                , T.items_center
                , theme.bgMenu
                ]
    in
    nav [ style ]
        [ viewBtnIndex theme
        , viewBtnNewThread theme
        , viewBtnDelete theme
        , viewBtnSettings theme
        ]


viewBtnIndex : Theme -> Html Msg
viewBtnIndex theme =
    a [ href <| Route.internalLink [] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Html.Attributes.title "Main Page"
            , classes [ T.dim, theme.fgMenuButton ]
            ]
            [ Icons.hedlx 32 ]
        ]


viewBtnNewThread : Theme -> Html Msg
viewBtnNewThread theme =
    a [ href <| Route.internalLink [ "new" ] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Html.Attributes.title "Start New Thread"
            , classes [ T.dim, theme.fgMenuButton ]
            ]
            [ Icons.add 32 ]
        ]


viewBtnDelete : Theme -> Html Msg
viewBtnDelete theme =
    let
        isEnabled =
            False

        dynamicAttrs =
            if isEnabled then
                [ Html.Attributes.title "Delete"
                , class theme.fgMenuButton
                ]

            else
                [ Html.Attributes.title "Delete\nYou need to select items before"
                , classes [ theme.fgMenuButtonDisabled ]
                ]
    in
    div ([ styleButtonMenu, Style.buttonIconic ] ++ dynamicAttrs)
        [ Icons.delete 32 ]


viewBtnSettings : Theme -> Html Msg
viewBtnSettings theme =
    div
        [ classes [ T.bottom_0_ns, T.right_0, T.absolute ]
        , styleButtonMenu
        , Style.buttonIconic
        , Html.Attributes.title "Settings"
        , onClick ToggleSettings
        , classes [ T.dim, theme.fgMenuButton ]
        , tabindex 0
        ]
        [ Icons.settings 32 ]


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
                , T.w_100
                , T.w_auto_ns
                , T.pa2
                , T.ml5_ns
                , T.pl2_ns
                , T.pb2_ns
                , T.bottom_0_ns
                , T.mt5
                , T.z_max
                , Animations.fadein_left_ns
                , Animations.fadein_top_s
                ]

        style =
            classes
                [ T.w_100
                , T.br2
                , theme.fgSettings
                , theme.bgSettings
                , theme.shadowSettings
                ]
    in
    aside [ styleContainer ]
        [ div [ style ]
            [ viewSettingsHeader theme
            , viewSettingsOptions theme cfg
            ]
        ]


viewSettingsHeader : Theme -> Html Msg
viewSettingsHeader theme =
    div [ classes [ T.w_100, T.h2, T.pa1 ] ]
        [ viewButtonCloseSettings theme ]


viewButtonCloseSettings : Theme -> Html Msg
viewButtonCloseSettings _ =
    div
        [ classes [ T.fr, T.dim ]
        , onClick ToggleSettings
        , Style.buttonIconic
        , title "Close"
        ]
        [ Icons.close 20 ]


viewSettingsOptions : Theme -> Config -> Html Msg
viewSettingsOptions theme cfg =
    div [ class T.pa3 ]
        [ viewSettingsOption "Name"
            [ viewOptionStringInput theme "text" SettingsNameChanged cfg.name Env.defaultName ]
        , viewSettingsOption "Trip Secret"
            [ viewOptionStringInput theme "text" SettingsTripChanged cfg.trip "" ]
        , viewSettingsOption "Password"
            [ viewOptionStringInput theme "password" SettingsPassChanged cfg.pass "" ]
        , viewSettingsOption "UI Theme"
            [ viewSelectTheme theme ]
        , viewButtonResetSettings theme
        ]


viewOptionStringInput : Theme -> String -> (String -> Msg) -> String -> String -> Html Msg
viewOptionStringInput theme inputType toMsg currentValue placegolderValue =
    let
        style =
            classes
                [ T.f7
                , T.pa1
                , T.br1
                , T.b__solid
                , theme.fontMono
                , theme.fgInput
                , theme.bgInput
                , theme.bInput
                ]
    in
    input
        [ type_ inputType
        , value currentValue
        , style
        , onInput toMsg
        , placeholder placegolderValue
        ]
        []


viewSettingsOption : String -> List (Html Msg) -> Html Msg
viewSettingsOption settingLabel optionBody =
    div [ classes [ T.h2, T.mb2 ] ]
        [ div [ classes [ T.fl, T.mr3, T.pt1 ] ] [ text settingLabel ]
        , div [ classes [ T.fr ] ] optionBody
        ]


viewSelectTheme : Theme -> Html Msg
viewSelectTheme currentTheme =
    let
        style =
            classes
                [ T.br1
                , T.pa1
                , T.f6
                , T.outline_0
                , currentTheme.bInput
                , currentTheme.fgInput
                , currentTheme.bgInput
                ]
    in
    select [ style, onChange SettingsThemeChanged ] <|
        Dict.foldr (addSelectThemeOption currentTheme) [] Theme.builtIn


addSelectThemeOption : Theme -> Theme.ID -> Theme -> List (Html Msg) -> List (Html Msg)
addSelectThemeOption currentTheme themeID theme options =
    option
        [ Html.Attributes.style "background-color" "#eee"
        , Html.Attributes.style "color" "#000"
        , value themeID
        , selected (currentTheme.id == themeID)
        ]
        [ text theme.name ]
        :: options


viewButtonResetSettings : Theme -> Html Msg
viewButtonResetSettings theme =
    let
        style =
            classes
                [ T.w_100
                , T.tc
                , T.f6
                , T.br2
                , T.pa1
                , T.outline_0
                , theme.bInput
                , theme.fgButton
                , theme.bgButton
                ]
    in
    button
        [ style
        , Style.buttonEnabled theme
        , onClick SettingsReset
        , title "Resets settings and cleans all BBS data from the browser storage"
        ]
        [ text "Reset Settings" ]
