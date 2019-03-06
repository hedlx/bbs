module Route exposing (route)

import Dict
import Env
import Model.Page as Page exposing (..)
import Model.ThreadForm as ThreadForm exposing (ThreadForm)
import Regex
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing (..)


routes =
    [ top |> map (Index <| Loading ())
    , s "new" |> map (NewThread ThreadForm.empty)
    , s "threads" |> map (Index <| Loading ())
    , s "threads" </> int |> map (\tID -> Thread <| Loading tID)
    , s "threads" </> s "new" |> map (NewThread ThreadForm.empty)
    ]


route : Url -> Page
route =
    replacePathWithFragment
        >> parse (oneOf routes)
        >> Maybe.withDefault NotFound


replacePathWithFragment url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Just ""
    }
