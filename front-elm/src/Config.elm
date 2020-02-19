module Config exposing
    ( Config
    , Msg
    , Response
    , encodeUserSettings
    , init
    , maxLineLength
    , mergeFlags
    , perPageThreads
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
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Events.Extra exposing (onChange)
import Http
import IO
import IntField exposing (IntField)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import Json.Encode as Encode
import Limits exposing (Limits)
import Route exposing (Route)
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
            { urlApi = Url.Builder.crossOrigin Env.defaultUrlServer Env.defaultApiPath []
            , urlImage = Url.Builder.crossOrigin Env.defaultUrlServer Env.defaultImagePath []
            , urlThumb = Url.Builder.crossOrigin Env.defaultUrlServer Env.defaultThumbPath []
            , key = key
            , urlApp = normalizedUrl
            , theme = Theme.default
            , name = defaultUserSettings.name
            , trip = defaultUserSettings.trip
            , pass = defaultUserSettings.pass
            , perPageThreads = defaultUserSettings.perPageThreads
            , maxLineLength = defaultUserSettings.maxLineLength
            , limits = Limits.empty
            , timeZone = Nothing
            }
                |> mergeFlags flags
    in
    ( cfg, fetch cfg )



-- MODEL


type alias Config =
    { urlApi : String
    , urlImage : String
    , urlThumb : String
    , key : Nav.Key
    , urlApp : Url
    , theme : Theme
    , name : String
    , trip : String
    , pass : String
    , perPageThreads : IntField
    , maxLineLength : IntField
    , limits : Limits
    , timeZone : Maybe Zone
    }


mergeFlags : Encode.Value -> Config -> Config
mergeFlags flags cfg =
    let
        urlServer =
            Decode.decodeValue (Decode.field "urlServer" Decode.string) flags
                |> Result.withDefault Env.defaultUrlServer

        userSettings =
            Decode.decodeValue (Decode.field "settings" decoderUserSettings) flags
                |> Result.withDefault defaultUserSettings
    in
    { cfg
        | urlApi = Url.Builder.crossOrigin urlServer Env.defaultApiPath []
        , urlImage = Url.Builder.crossOrigin urlServer Env.defaultImagePath []
        , urlThumb = Url.Builder.crossOrigin urlServer Env.defaultThumbPath []
        , name = userSettings.name
        , trip = userSettings.trip
        , pass = userSettings.pass
        , theme = userSettings.theme
        , perPageThreads = userSettings.perPageThreads
        , maxLineLength = userSettings.maxLineLength
    }


perPageThreads : Config -> Int
perPageThreads cfg =
    IntField.toInt cfg.perPageThreads


maxLineLength : Config -> Int
maxLineLength cfg =
    IntField.toInt cfg.maxLineLength


type alias UserSettings =
    { name : String
    , trip : String
    , pass : String
    , theme : Theme
    , perPageThreads : IntField
    , maxLineLength : IntField
    }


domIDperPageThreadsField : String
domIDperPageThreadsField =
    "per-page-threads"


limitsPerPageThreads : IntField.Limits
limitsPerPageThreads =
    ( Env.minPerPage, Env.threadsPerPage, Env.maxPerPage )


limitsMaxLineLength : IntField.Limits
limitsMaxLineLength =
    ( Env.minLineLength, Env.lineLength, Env.maxLineLength )


defaultUserSettings : UserSettings
defaultUserSettings =
    { name = ""
    , trip = ""
    , pass = ""
    , theme = Theme.default
    , perPageThreads = IntField.fromLimits limitsPerPageThreads
    , maxLineLength = IntField.fromLimits limitsMaxLineLength
    }


decoderUserSettings : Decoder UserSettings
decoderUserSettings =
    Decode.map6 UserSettings
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
            Decode.at [ "settings", "perPageThreads" ] (IntField.decoder limitsPerPageThreads)
        )
        (DecodeExt.withDefault defaultUserSettings.maxLineLength <|
            Decode.at [ "settings", "maxLineLength" ] (IntField.decoder limitsMaxLineLength)
        )


encodeUserSettings : Config -> Encode.Value
encodeUserSettings cfg =
    Encode.object
        [ ( "name", Encode.string cfg.name )
        , ( "trip", Encode.string cfg.trip )
        , ( "pass", Encode.string cfg.pass )
        , ( "theme", Theme.encode cfg.theme )
        , ( "perPageThreads", IntField.encode cfg.perPageThreads )
        , ( "maxLineLength", IntField.encode cfg.maxLineLength )
        ]


resetUserSettings : Config -> Config
resetUserSettings cfg =
    { cfg
        | name = defaultUserSettings.name
        , trip = defaultUserSettings.trip
        , pass = defaultUserSettings.pass
        , theme = defaultUserSettings.theme
        , perPageThreads = defaultUserSettings.perPageThreads
        , maxLineLength = defaultUserSettings.maxLineLength
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
                getLimits cfg

            else
                Cmd.none
    in
    Cmd.batch [ fetchTimeZone, fetchLimits ]


getTimeZone : Cmd Msg
getTimeZone =
    Time.here |> Task.perform GotTimeZone


getLimits : Config -> Cmd Msg
getLimits { urlApi } =
    Http.get
        { url = Url.Builder.crossOrigin urlApi [ "limits" ] []
        , expect = Http.expectJson GotLimits Limits.decoder
        }


saveUserSettings : Config -> Cmd Msg
saveUserSettings cfg =
    IO.saveUserSettings (encodeUserSettings cfg)



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
    | SetMaxLineLength Int


type alias Response =
    ( Config, Cmd Msg, Alert Msg )


update : Maybe Route -> Msg -> Config -> Response
update maybeRoute msg cfg =
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
            , IO.cleanUserSettings ()
            , Alert.None
            )

        GotLimits (Ok newLimits) ->
            return { cfg | limits = newLimits }

        GotLimits (Err _) ->
            raise cfg alertFailedRetrieveData

        GotTimeZone newZone ->
            return { cfg | timeZone = Just newZone }

        EditPerPageThreads ->
            return { cfg | perPageThreads = IntField.edit cfg.perPageThreads }

        ChangePerPageThreads str ->
            return { cfg | perPageThreads = IntField.updateString str cfg.perPageThreads }

        SubmitPerPageThreads ->
            let
                ( newCfg, cmdSave, _ ) =
                    save { cfg | perPageThreads = IntField.submit cfg.perPageThreads }

                isIndexPage =
                    Maybe.map Route.isIndex maybeRoute
                        |> Maybe.withDefault False

                cmdReloadIndex =
                    if isIndexPage && IntField.isChanged cfg.perPageThreads then
                        Nav.pushUrl cfg.key (Route.link Route.index)

                    else
                        Cmd.none

                cmdUnfocus =
                    Dom.blur domIDperPageThreadsField |> Task.attempt (\_ -> NoOp)
            in
            ( newCfg
            , Cmd.batch [ cmdUnfocus, cmdSave, cmdReloadIndex ]
            , Alert.None
            )

        SetMaxLineLength newVal ->
            save { cfg | maxLineLength = IntField.update newVal cfg.maxLineLength }


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
    IO.userSettingsChanged SettingsStorageChanged



-- VIEW


viewUserSettings : Config -> Html Msg
viewUserSettings ({ theme, name, trip, pass } as cfg) =
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
            [ IntField.input
                { onEdit = EditPerPageThreads
                , onChange = ChangePerPageThreads
                , onSubmit = SubmitPerPageThreads
                }
                [ id domIDperPageThreadsField
                , class T.w3
                , styleInput theme
                ]
                cfg.perPageThreads
            ]
        , viewOption "Max Line Length"
            [ IntField.range
                { onChange = SetMaxLineLength }
                [ class T.w4 ]
                cfg.maxLineLength
            , div [ classes [ T.f6, T.dib, T.w2, T.ml2, T.fr ] ]
                [ text (IntField.toString cfg.maxLineLength) ]
            ]
        , viewBtnReset theme
        ]


viewOption : String -> List (Html Msg) -> Html Msg
viewOption settingLabel optionBody =
    div [ classes [ T.h2, T.mb2 ] ]
        [ div [ classes [ T.fl, T.mr3, T.pt1 ] ] [ text settingLabel ]
        , div [ classes [ T.fr ] ] optionBody
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
        [ value themeID
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
