module Config exposing
    ( Config
    , Msg
    , Response
    , encodeUserSettings
    , init
    , mergeFlags
    , perPageToInt
    , subscriptions
    , update
    , viewUserSettings
    )

import Alert exposing (Alert)
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Dict
import Env
import Html exposing (..)
import Html.Attributes as Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onChange)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import Json.Encode as Encode
import Keyboard
import Keyboard.Events as KeyboardEv
import Limits exposing (Limits)
import LocalStorage
import Regex exposing (Regex)
import Route
import String.Extra
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Task
import Theme exposing (Theme)
import Time exposing (Zone)
import Url exposing (Url)
import Url.Builder


init : Encode.Value -> Url -> Nav.Key -> ( Config, Cmd Msg )
init flags url key =
    let
        normalizedUrl =
            { url
                | path =
                    String.split "/" url.path
                        |> List.filter (not << String.Extra.isBlank)
                        >> String.join "/"
            }

        cfg =
            { key = key
            , urlApp = normalizedUrl
            , theme = Theme.default
            , name = defaultUserSettings.name
            , trip = defaultUserSettings.trip
            , pass = defaultUserSettings.pass
            , perPageThreads = defaultUserSettings.perPageThreads
            , limits = Limits.empty
            , timeZone = Nothing
            }
                |> mergeFlags flags
    in
    ( cfg, fetch cfg )



-- MODEL


type alias Config =
    { key : Nav.Key
    , urlApp : Url
    , theme : Theme
    , name : String
    , trip : String
    , pass : String
    , perPageThreads : PerPage
    , limits : Limits
    , timeZone : Maybe Zone
    }


mergeFlags : Encode.Value -> Config -> Config
mergeFlags flags cfg =
    let
        userSettings =
            Decode.decodeValue (Decode.field "settings" decoderUserSettings) flags
                |> Result.withDefault defaultUserSettings
    in
    { cfg
        | name = userSettings.name
        , trip = userSettings.trip
        , pass = userSettings.pass
        , theme = userSettings.theme
        , perPageThreads = userSettings.perPageThreads
    }


type PerPage
    = PerPageDefault
    | PerPage Int
    | PerPageEdit Int String


perPageThreadsFieldID : String
perPageThreadsFieldID =
    "per-page-threads"


editPerPage : Int -> PerPage -> PerPage
editPerPage perPageDefault perPage =
    case perPage of
        PerPageDefault ->
            PerPageEdit perPageDefault (String.fromInt perPageDefault)

        PerPage n ->
            PerPageEdit n (String.fromInt n)

        _ ->
            perPage


submitPerPage : PerPage -> PerPage
submitPerPage perPage =
    case perPage of
        PerPageEdit _ str ->
            perPageFromString str

        _ ->
            perPage


setPerPageEdit : String -> PerPage -> PerPage
setPerPageEdit str perPage =
    if Regex.contains regexPerPageEdit str then
        case perPage of
            PerPageEdit n _ ->
                PerPageEdit n str

            _ ->
                perPage

    else
        perPage


isPerPageChanged : PerPage -> Bool
isPerPageChanged perPage =
    case perPage of
        PerPageEdit n str ->
            String.toInt str /= Just n

        _ ->
            False


regexPerPageEdit : Regex
regexPerPageEdit =
    Regex.fromString "^\\d*$"
        |> Maybe.withDefault Regex.never


decoderPerPage : Decoder PerPage
decoderPerPage =
    DecodeExt.withDefault PerPageDefault <|
        Decode.map perPageFromInt Decode.int


perPageFromString : String -> PerPage
perPageFromString str =
    Decode.decodeString decoderPerPage str
        |> Result.withDefault PerPageDefault


perPageFromInt : Int -> PerPage
perPageFromInt n =
    if n < Env.minPerPage then
        PerPage Env.minPerPage

    else if Env.maxPerPage < n then
        PerPage Env.maxPerPage

    else
        PerPage n


encodePerPage : PerPage -> Encode.Value
encodePerPage perPage =
    case perPage of
        PerPage n ->
            Encode.int n

        _ ->
            Encode.null


perPageToStr : PerPage -> Maybe String
perPageToStr perPage =
    case perPage of
        PerPageEdit _ val ->
            Just val

        PerPage n ->
            Just (String.fromInt n)

        PerPageDefault ->
            Nothing


perPageToInt : PerPage -> Maybe Int
perPageToInt perPage =
    case perPage of
        PerPage n ->
            Just n

        _ ->
            Nothing


type alias UserSettings =
    { name : String
    , trip : String
    , pass : String
    , theme : Theme
    , perPageThreads : PerPage
    }


defaultUserSettings : UserSettings
defaultUserSettings =
    { name = ""
    , trip = ""
    , pass = ""
    , theme = Theme.default
    , perPageThreads = PerPageDefault
    }


decoderUserSettings : Decoder UserSettings
decoderUserSettings =
    Decode.map5 UserSettings
        (DecodeExt.withDefault defaultUserSettings.name <|
            Decode.at [ "settings", "name" ] Decode.string
        )
        (DecodeExt.withDefault defaultUserSettings.trip <|
            Decode.at [ "settings", "trip" ] Decode.string
        )
        (DecodeExt.withDefault defaultUserSettings.pass <|
            Decode.at [ "settings", "pass" ] Decode.string
        )
        (DecodeExt.withDefault defaultUserSettings.theme <|
            Decode.at [ "settings", "theme" ] Theme.decoder
        )
        (DecodeExt.withDefault defaultUserSettings.perPageThreads <|
            Decode.at [ "settings", "perPageThreads" ] decoderPerPage
        )


encodeUserSettings : Config -> Encode.Value
encodeUserSettings cfg =
    Encode.object
        [ ( "name", Encode.string cfg.name )
        , ( "trip", Encode.string cfg.trip )
        , ( "pass", Encode.string cfg.pass )
        , ( "theme", Theme.encode cfg.theme )
        , ( "perPageThreads", encodePerPage cfg.perPageThreads )
        ]


resetUserSettings : Config -> Config
resetUserSettings cfg =
    { cfg
        | name = defaultUserSettings.name
        , trip = defaultUserSettings.trip
        , pass = defaultUserSettings.pass
        , theme = defaultUserSettings.theme
    }


fetch : Config -> Cmd Msg
fetch cfg =
    let
        fetchTimeZone =
            if cfg.timeZone == Nothing then
                getTimeZone

            else
                Cmd.none

        fetchLimits =
            if Limits.hasUndefined cfg.limits then
                getLimits

            else
                Cmd.none
    in
    Cmd.batch [ fetchTimeZone, fetchLimits ]


getTimeZone : Cmd Msg
getTimeZone =
    Time.here |> Task.perform GotTimeZone


getLimits : Cmd Msg
getLimits =
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "limits" ] []
        , expect = Http.expectJson GotLimits Limits.decoder
        }


saveUserSettings : Config -> Cmd Msg
saveUserSettings cfg =
    LocalStorage.saveUserSettings (encodeUserSettings cfg)



-- UPDATE


type Msg
    = NoOp
    | GotLimits (Result Http.Error Limits)
    | GotTimeZone Zone
    | SetTheme Theme.ID
    | SetName String
    | SetTrip String
    | SetPass String
    | ResetSettingsWithConfirmation
    | ResetSettings
    | SettingsStorageChanged Encode.Value
    | EditPerPageThreads
    | ChangePerPageThreads String
    | SubmitPerPageThreads


type alias Response =
    ( Config, Cmd Msg, Alert Msg )


update : Msg -> Config -> Response
update msg cfg =
    case msg of
        NoOp ->
            return cfg

        SetTheme newThemeID ->
            let
                newTheme =
                    Theme.selectBuiltIn newThemeID
            in
            save { cfg | theme = newTheme }

        SettingsStorageChanged newFlags ->
            return (mergeFlags newFlags cfg)

        SetName newName ->
            save { cfg | name = newName }

        SetTrip newTrip ->
            save { cfg | trip = newTrip }

        SetPass newPass ->
            save { cfg | pass = newPass }

        ResetSettingsWithConfirmation ->
            raise cfg alertResetSettings

        ResetSettings ->
            ( resetUserSettings cfg
            , LocalStorage.cleanUserSettings ()
            , Alert.None
            )

        GotLimits (Ok newLimits) ->
            return { cfg | limits = newLimits }

        GotLimits (Err _) ->
            raise cfg alertFailedRetrieveData

        GotTimeZone newZone ->
            return { cfg | timeZone = Just newZone }

        EditPerPageThreads ->
            return
                { cfg
                    | perPageThreads = editPerPage Env.threadsPerPage cfg.perPageThreads
                }

        ChangePerPageThreads str ->
            return
                { cfg
                    | perPageThreads = setPerPageEdit str cfg.perPageThreads
                }

        SubmitPerPageThreads ->
            let
                newPerPageThreads =
                    submitPerPage cfg.perPageThreads

                ( newCfg, cmdSave, _ ) =
                    save { cfg | perPageThreads = newPerPageThreads }

                cmdReloadIndex =
                    if isPerPageChanged cfg.perPageThreads then
                        Nav.pushUrl cfg.key (Route.link Route.index)

                    else
                        Cmd.none

                cmdUnfocus =
                    Dom.blur perPageThreadsFieldID |> Task.attempt (\_ -> NoOp)
            in
            ( newCfg
            , Cmd.batch [ cmdUnfocus, cmdSave, cmdReloadIndex ]
            , Alert.None
            )


return : Config -> Response
return cfg =
    ( cfg, Cmd.none, Alert.None )


save : Config -> Response
save cfg =
    ( cfg, saveUserSettings cfg, Alert.None )


raise : Config -> Alert Msg -> Response
raise cfg alert =
    ( cfg, Cmd.none, alert )


alertResetSettings : Alert Msg
alertResetSettings =
    Alert.Confirm
        "Are you sure?"
        "Your name, password and tripcode will be lost."
        ResetSettings


alertFailedRetrieveData : Alert Msg
alertFailedRetrieveData =
    Alert.Warning
        "Failed to get metadata from the server"
        """ 
        App functionality can be restricted. 
        Please, check your Internet connection and reload the page.
        """



-- SUBSCRIPTIONS


subscriptions : Config -> Sub Msg
subscriptions _ =
    LocalStorage.userSettingsChanged SettingsStorageChanged



-- VIEW


viewUserSettings : Config -> Html Msg
viewUserSettings { theme, name, trip, pass, perPageThreads } =
    div [ class T.pa3 ]
        [ viewOption "Name"
            [ viewStringInput theme "text" SetName name Env.defaultName ]
        , viewOption "Trip Secret"
            [ viewStringInput theme "text" SetTrip trip "" ]
        , viewOption "Password"
            [ viewStringInput theme "password" SetPass pass "" ]
        , viewOption "UI Theme"
            [ viewSelectTheme theme ]
        , viewOption "Threads / Page"
            [ viewPerPageThreadsInput theme perPageThreads ]
        , viewBtnReset theme
        ]


viewStringInput : Theme -> String -> (String -> Msg) -> String -> String -> Html Msg
viewStringInput theme inputType toMsg currentValue placeholderValue =
    input
        [ type_ inputType
        , value currentValue
        , styleInput theme
        , onInput toMsg
        , placeholder placeholderValue
        ]
        []


viewPerPageThreadsInput : Theme -> PerPage -> Html Msg
viewPerPageThreadsInput theme currentPerPage =
    let
        strDefault =
            String.fromInt Env.threadsPerPage

        currentVal =
            perPageToStr currentPerPage
                |> Maybe.withDefault strDefault
    in
    input
        [ id perPageThreadsFieldID
        , type_ "number"
        , class T.w3
        , styleInput theme
        , Attributes.min (String.fromInt Env.minPerPage)
        , Attributes.max (String.fromInt Env.maxPerPage)
        , value currentVal
        , placeholder strDefault
        , onFocus EditPerPageThreads
        , onBlur (\_ -> SubmitPerPageThreads)
        , onInput ChangePerPageThreads
        , KeyboardEv.on KeyboardEv.Keydown
            [ ( Keyboard.Escape, SubmitPerPageThreads )
            , ( Keyboard.Enter, SubmitPerPageThreads )
            ]
        ]
        []


onBlur : (String -> msg) -> Attribute msg
onBlur tagger =
    on "blur" (Decode.map tagger targetValue)


styleInput : Theme -> Attribute Msg
styleInput theme =
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


viewOption : String -> List (Html Msg) -> Html Msg
viewOption settingLabel optionBody =
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
        [ Attributes.style "background-color" "#eee"
        , Attributes.style "color" "#000"
        , value themeID
        , selected (currentTheme.id == themeID)
        ]
        [ text theme.name ]
        :: options


viewBtnReset : Theme -> Html Msg
viewBtnReset theme =
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
