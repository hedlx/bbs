module Model exposing (Flags, Model, empty)

import Json.Encode as Encode
import Model.Theme as Theme exposing (Theme)
import Model.Thread as Thread exposing (Thread)
import Spinner


type alias Flags =
    Encode.Value


type alias Model =
    { isLoading : Bool
    , theme : Theme
    , threads : List Thread
    , spinner : Spinner.Model
    }


empty =
    { isLoading = True
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
