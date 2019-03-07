module Route exposing (link, route)

import Dict
import Env
import Model.Page as Page exposing (..)
import Model.PostForm as PostForm exposing (PostForm)
import Regex
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing (..)


routes =
    [ top |> map (Index <| Loading ())
    , s "new" |> map (NewThread PostForm.empty)
    , s "threads" |> map (Index <| Loading ())
    , s "threads" </> int |> map (\tID -> Thread <| Loading tID)
    , s "threads" </> s "new" |> map (NewThread PostForm.empty)
    ]


route : Url -> Page
route =
    replacePathWithFragment
        >> parse (oneOf routes)
        >> Maybe.withDefault NotFound


link : Url -> List String -> String
link urlApp ls =
    Builder.relative (urlApp.path :: "#" :: ls) []


replacePathWithFragment url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Just ""
    }
