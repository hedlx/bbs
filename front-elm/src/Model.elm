module Model exposing (Flags, Model, init)

import Browser.Navigation as Nav
import Json.Encode as Encode
import Model.Config as Config exposing (Config)
import Model.Page as Page exposing (Page)
import Model.Theme as Theme exposing (Theme)
import Route
import Spinner
import Url exposing (Url)


type alias Flags =
    Encode.Value


type alias Model =
    { cfg : Config
    , page : Page
    , key : Nav.Key
    , theme : Theme
    , spinner : Spinner.Model
    }


init flags url key =
    { cfg = Config.init url
    , page = Route.route url
    , key = key
    , theme = Theme.empty
    , spinner = Spinner.init
    }
