module Model.Config exposing (Config, init)

import Browser.Navigation as Nav
import Model.Limits as Limits exposing (Limits)
import Model.Theme as Theme exposing (Theme)
import String.Extra
import Url exposing (Url)


type alias Config =
    { key : Nav.Key
    , urlApp : Url
    , theme : Theme
    , limits : Limits
    }


init url key =
    { key = key
    , urlApp = normalizeUrl url
    , theme = Theme.empty
    , limits = Limits.empty
    }


normalizeUrl url =
    { url
        | path =
            String.split "/" url.path
                |> List.filter (not << String.Extra.isBlank)
                >> String.join "/"
    }
