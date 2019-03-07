module Model.Config exposing (Config, init)

import Url exposing (Url)


type alias Config =
    { urlApp : Url
    }


init url =
    { urlApp = url
    }
