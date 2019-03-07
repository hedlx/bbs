module Route exposing (internalLink, route)

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
    oneOf
        [ oneOf [ top, s "threads" ] |> map (Index <| Loading ())
        , oneOf [ s "new", s "threads" </> s "new" ] |> map (NewThread PostForm.empty)
        , oneOf [ int, s "threads" </> int ] |> map (\tID -> Thread <| Loading tID)
        ]


route : Url -> Page
route =
    replacePathWithFragment
        >> parse routes
        >> Maybe.withDefault NotFound


internalLink : List String -> String
internalLink ls =
    let
        fixedPath =
            List.concatMap (String.split "/") ls
                |> List.filter (not << String.Extra.isBlank)
    in
       Builder.relative ("#" :: fixedPath) []


replacePathWithFragment url =
    { url
        | path = Maybe.withDefault "" url.fragment
        , fragment = Just ""
    }
