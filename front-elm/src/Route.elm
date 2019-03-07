module Route exposing (link, route)

import Dict
import Env
import Model.Page as Page exposing (..)
import Model.PostForm as PostForm exposing (PostForm)
import Regex
import String.Extra
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing (..)


routes =
    [ oneOf [ top, s "threads" ] |> map (Index <| Loading ())
    , oneOf [ s "new", s "threads" </> s "new" ] |> map (NewThread PostForm.empty)
    , oneOf [ int, s "threads" </> int ] |> map (\tID -> Thread <| Loading tID)
    ]


route : Url -> Page
route =
    replacePathWithFragment
        >> parse (oneOf routes)
        >> Maybe.withDefault NotFound


link : Url -> List String -> String
link urlApp ls =
    let
        fixedAppPath =
            String.split "/" urlApp.path
                |> List.filter (not << String.Extra.isBlank)

        fixedPath =
            ls
                |> List.concatMap (String.split "/")
                >> List.filter (not << String.Extra.isBlank)
    in
    Builder.relative fixedAppPath []
        ++ "#"
        ++ Builder.relative fixedPath []


replacePathWithFragment url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Just ""
    }
