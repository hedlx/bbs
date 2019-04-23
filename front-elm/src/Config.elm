module Config exposing
    ( Config
    , fetch
    , init
    , setLimits
    , setTheme
    , setTimeZone
    , toggleSettings
    )

import Browser.Navigation as Nav
import Env
import Http
import Limits exposing (Limits)
import String.Extra
import Task
import Theme exposing (Theme)
import Time exposing (Zone)
import Url exposing (Url)
import Url.Builder


type alias Config =
    { key : Nav.Key
    , urlApp : Url
    , theme : Theme
    , limits : Limits
    , timeZone : Maybe Zone
    , isSettingsVisible : Bool
    }


init : Url -> Nav.Key -> Config
init url key =
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
    , limits = Limits.empty
    , timeZone = Nothing
    , isSettingsVisible = False
    }


setTheme : Theme -> Config -> Config
setTheme newTheme cfg =
    { cfg | theme = newTheme }


setLimits : Limits -> Config -> Config
setLimits newLimits cfg =
    { cfg | limits = newLimits }


setTimeZone : Zone -> Config -> Config
setTimeZone newZone cfg =
    { cfg | timeZone = Just newZone }


toggleSettings : Config -> Config
toggleSettings cfg =
    { cfg | isSettingsVisible = not cfg.isSettingsVisible }


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
