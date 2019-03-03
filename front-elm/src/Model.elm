module Model exposing (Flags, Model, init)

import Browser.Navigation as Nav
import Json.Encode as Encode
import Model.Page exposing (Page)
import Model.Theme as Theme exposing (Theme)
import Model.Thread as Thread exposing (Thread)
import Route
import Spinner
import Url exposing (Url)


type alias Flags =
    Encode.Value


type alias Model =
    { page : Page
    , key : Nav.Key
    , isLoading : Bool
    , theme : Theme
    , threads : List Thread
    , spinner : Spinner.Model
    }


init flags url key =
    { page = Route.route url
    , key = key
    , isLoading = True
    , theme = Theme.empty
    , threads = []
    , spinner = Spinner.init
    }



-- testThread =
--     { id = 1
--     , op =
--         { no = 0
--         , name = "Anon"
--         , trip = "123"
--         , text = "Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda"
--         }
--     , replies =
--         [ { no = 1
--           , name = "Anon"
--           , trip = "123"
--           , text = "Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda Hello Proda"
--           }
--         ]
--     }
