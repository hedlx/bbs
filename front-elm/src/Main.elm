module Main exposing (main)

import Alert exposing (Alert)
import Browser
import Browser.Navigation as Nav
import Config exposing (Config)
import Dialog exposing (Dialog)
import Dict
import Env
import FilesDrop
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
import SlideIn exposing (SlideIn)
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


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        cfg =
            Config.init flags url key

        cmdFetchConfig =
            Config.fetch
                { onGotTimeZone = GotTimeZone
                , onGotLimits = GotLimits
                }
                model.cfg

        ( model, cmd ) =
            route cfg
                url
                { cfg = cfg
                , page = Page.NotFound
                , isSettingsVisible = False
                , slideIn = SlideIn.init
                , dialog = Dialog.closed
                }
    in
    ( model, Cmd.batch [ cmdFetchConfig, cmd ] )



-- MODEL


type alias Model =
    { cfg : Config
    , page : Page
    , isSettingsVisible : Bool
    , slideIn : SlideIn
    , dialog : Dialog Msg
    }



-- UPDATE


type Msg
    = NoOp
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | PageMsg Page.Msg
    | SlideInMsg SlideIn.Msg
    | GotLimits (Result Http.Error Limits)
    | GotTimeZone Zone
    | ToggleSettings
    | SettingsStorageChanged Encode.Value
    | SetTheme Theme.ID
    | SetName String
    | SetTrip String
    | SetPass String
    | ResetSettingsWithConfirmation
    | ResetSettings
    | CancelDialog
    | ConfirmDialog


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

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
            route model.cfg url model

        SlideInMsg subMsg ->
            let
                ( newSlideIn, cmd ) =
                    SlideIn.update subMsg model.slideIn
            in
            ( { model | slideIn = newSlideIn }, Cmd.map SlideInMsg cmd )

        GotLimits (Err _) ->
            let
                alert =
                    Alert.Warning
                        "Failed to get metadata from the server"
                        """ 
                        App functionality can be restricted. 
                        Please, check your Internet connection and reload the page.
                        """
            in
            dispatchAlert alert model

        GotLimits (Ok newLimits) ->
            ( mapConfig (Config.setLimits newLimits) model, Cmd.none )

        GotTimeZone newZone ->
            ( mapConfig (Config.setTimeZone newZone) model, Cmd.none )

        ToggleSettings ->
            ( { model | isSettingsVisible = not model.isSettingsVisible }, Cmd.none )

        SetTheme newThemeID ->
            let
                newTheme =
                    Theme.selectBuiltIn newThemeID

                newCfg =
                    Config.setTheme newTheme model.cfg
            in
            ( { model | cfg = newCfg }, saveUserSettings newCfg )

        SettingsStorageChanged newFlags ->
            ( mapConfig (Config.mergeFlags newFlags) model, Cmd.none )

        SetName newName ->
            updateUserSettings (Config.setName newName) model

        SetTrip newTrip ->
            updateUserSettings (Config.setTrip newTrip) model

        SetPass newPass ->
            updateUserSettings (Config.setPass newPass) model

        ResetSettingsWithConfirmation ->
            ( { model
                | dialog =
                    Dialog.visible
                        "Are you sure?"
                        "Your name, password and tripcode will be lost."
                        ResetSettings
              }
            , Cmd.none
            )

        ResetSettings ->
            ( mapConfig Config.resetUserSettings { model | dialog = Dialog.closed }
            , LocalStorage.cleanUserSettings ()
            )

        CancelDialog ->
            ( { model | dialog = Dialog.cancel model.dialog }, Cmd.none )

        ConfirmDialog ->
            let
                ( newDialog, maybeMsg ) =
                    Dialog.confirm model.dialog
            in
            case maybeMsg of
                Nothing ->
                    ( model, Cmd.none )

                Just confirmedMsg ->
                    update confirmedMsg { model | dialog = newDialog }


dispatchAlert : Alert Msg -> Model -> ( Model, Cmd Msg )
dispatchAlert alert model =
    case alert of
        Alert.None ->
            ( model, Cmd.none )

        Alert.Warning title desc ->
            let
                ( newSlideIn, cmd ) =
                    SlideIn.add (SlideIn.Warning title desc) model.slideIn
            in
            ( { model | slideIn = newSlideIn }, Cmd.map SlideInMsg cmd )

        Alert.Error title desc ->
            let
                ( newSlideIn, cmd ) =
                    SlideIn.add (SlideIn.Error title desc) model.slideIn
            in
            ( { model | slideIn = newSlideIn }, Cmd.map SlideInMsg cmd )

        Alert.Confirm title desc okMsg ->
            ( { model | dialog = Dialog.visible title desc okMsg }, Cmd.none )

        Alert.Batch alerts ->
            let
                dispatchBatch =
                    List.map dispatchAlert alerts
                        |> List.foldl Update.Extra.compose Update.Extra.return
            in
            dispatchBatch model


updatePage : ( Page, Cmd Page.Msg, Alert Page.Msg ) -> Model -> ( Model, Cmd Msg )
updatePage ( newPage, pageCmd, pageAlert ) model =
    let
        ( newModel, cmdAlert ) =
            dispatchAlert (Alert.map PageMsg pageAlert) model
    in
    ( { newModel | page = newPage }
    , Cmd.batch [ Cmd.map PageMsg pageCmd, cmdAlert ]
    )


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


route : Config -> Url -> Model -> ( Model, Cmd Msg )
route cfg url model =
    let
        urlFixed =
            toFragmentUrl url

        ( page, cmdPage ) =
            Page.init cfg urlFixed
    in
    ( { model | page = page }
    , Cmd.map PageMsg cmdPage
    )


toFragmentUrl : Url -> Url
toFragmentUrl url =
    { url | path = "/" }
        |> Url.toString
        >> Regex.replace regexFragmentBeginning (\_ -> "")
        >> Url.fromString
        >> Maybe.withDefault url


regexFragmentBeginning : Regex.Regex
regexFragmentBeginning =
    Regex.fromString "/#"
        |> Maybe.withDefault Regex.never



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    LocalStorage.userSettingsChanged SettingsStorageChanged



-- VIEW


view : Model -> Browser.Document Msg
view { cfg, page, isSettingsVisible, slideIn, dialog } =
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
        , main_
            [ styleBody

            -- Ignoring dropped files on top level to prevent
            , FilesDrop.onDragOver NoOp
            , FilesDrop.onDrop (\_ -> NoOp)
            ]
            [ viewNavigationMenu cfg
            , Dialog.view cfg.theme { onOk = ConfirmDialog, onCancel = CancelDialog } dialog
            , Html.Extra.viewIf isSettingsVisible (viewSettingsDialog cfg)
            , Html.map SlideInMsg (SlideIn.view cfg.theme slideIn)
            , Html.map PageMsg (Page.view cfg page)
            ]
        ]
    }


viewNavigationMenu : Config -> Html Msg
viewNavigationMenu cfg =
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
                , T.z_max
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
    a [ href (Route.link Route.Index) ]
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
    a [ href (Route.link Route.NewThread) ]
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
                , T.z_999
                , Animations.fadein_left_ns
                , Animations.fadein_top_s
                ]

        style =
            classes
                [ T.w_100
                , T.br2
                , theme.fgDialog
                , theme.bgDialog
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
            [ viewOptionStringInput theme "text" SetName cfg.name Env.defaultName ]
        , viewSettingsOption "Trip Secret"
            [ viewOptionStringInput theme "text" SetTrip cfg.trip "" ]
        , viewSettingsOption "Password"
            [ viewOptionStringInput theme "password" SetPass cfg.pass "" ]
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
    select [ style, onChange SetTheme ] <|
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
        , onClick ResetSettingsWithConfirmation
        , title "Resets settings and cleans all BBS data from the browser storage"
        ]
        [ text "Reset Settings" ]
