module Config exposing
    ( Config
    , encodeUserSettings
    , fetch
    , init
    , mergeFlags
    , resetUserSettings
    , setLimits
    , setName
    , setPass
    , setTheme
    , setTimeZone
    , setTrip
    )

import Browser.Navigation as Nav
import Env
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import Json.Encode as Encode
import Limits exposing (Limits)
import String.Extra
import Task
import Theme exposing (Theme)
import Time exposing (Zone)
import Url exposing (Url)
import Url.Builder


init : Encode.Value -> Url -> Nav.Key -> Config
init flags url key =
    let
        normalizedUrl =
            { url
                | path =
                    String.split "/" url.path
                        |> List.filter (not << String.Extra.isBlank)
                        >> String.join "/"
            }
    in
    { key = key
    , urlApp = normalizedUrl
    , theme = Theme.default
    , name = ""
    , trip = ""
    , pass = ""
    , limits = Limits.empty
    , timeZone = Nothing
    }
        |> mergeFlags flags


type alias Config =
    { key : Nav.Key
    , urlApp : Url
    , theme : Theme
    , name : String
    , trip : String
    , pass : String
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
    }


setTheme : Theme -> Config -> Config
setTheme newTheme cfg =
    { cfg | theme = newTheme }


setName : String -> Config -> Config
setName newName cfg =
    { cfg | name = newName }


setTrip : String -> Config -> Config
setTrip newTrip cfg =
    { cfg | trip = newTrip }


setPass : String -> Config -> Config
setPass newPass cfg =
    { cfg | pass = newPass }


setLimits : Limits -> Config -> Config
setLimits newLimits cfg =
    { cfg | limits = newLimits }


setTimeZone : Zone -> Config -> Config
setTimeZone newZone cfg =
    { cfg | timeZone = Just newZone }


type alias UserSettings =
    { name : String
    , trip : String
    , pass : String
    , theme : Theme
    }


defaultUserSettings : UserSettings
defaultUserSettings =
    { name = ""
    , trip = ""
    , pass = ""
    , theme = Theme.default
    }


decoderUserSettings : Decoder UserSettings
decoderUserSettings =
    Decode.map4 UserSettings
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


encodeUserSettings : Config -> Encode.Value
encodeUserSettings cfg =
    Encode.object
        [ ( "name", Encode.string cfg.name )
        , ( "trip", Encode.string cfg.trip )
        , ( "pass", Encode.string cfg.pass )
        , ( "theme", Theme.encode cfg.theme )
        ]


resetUserSettings : Config -> Config
resetUserSettings cfg =
    { cfg
        | name = defaultUserSettings.name
        , trip = defaultUserSettings.trip
        , pass = defaultUserSettings.pass
        , theme = defaultUserSettings.theme
    }


type alias FetchMessages msg =
    { onGotTimeZone : Zone -> msg
    , onGotLimits : Result Http.Error Limits -> msg
    }


fetch : FetchMessages msg -> Config -> Cmd msg
fetch toMsg cfg =
    let
        fetchTimeZone =
            if cfg.timeZone == Nothing then
                getTimeZone toMsg.onGotTimeZone

            else
                Cmd.none

        fetchLimits =
            if Limits.hasUndefined cfg.limits then
                getLimits toMsg.onGotLimits

            else
                Cmd.none
    in
    Cmd.batch [ fetchTimeZone, fetchLimits ]


getTimeZone : (Zone -> msg) -> Cmd msg
getTimeZone toMsg =
    Time.here |> Task.perform toMsg


getLimits : (Result Http.Error Limits -> msg) -> Cmd msg
getLimits toMsg =
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "limits" ] []
        , expect = Http.expectJson toMsg Limits.decoder
        }
