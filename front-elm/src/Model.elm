module Model exposing (Flags, Model)

import Json.Encode as Encode
import Model.Config as Config exposing (Config)
import Model.Page as Page exposing (Page)


type alias Flags =
    Encode.Value


type alias Model =
    { cfg : Config
    , page : Page
    }
