module Model.Config exposing (Config, init)

import String.Extra
import Url exposing (Url)


type alias Config =
    { urlApp : Url
    }


init url =
    { urlApp = normalizeUrl url
    }


normalizeUrl url =
    { url
        | path =
            String.split "/" url.path
                |> List.filter (not << String.Extra.isBlank)
                >> String.join "/"
    }
