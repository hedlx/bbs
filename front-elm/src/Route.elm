module Route exposing (internalLink, route)

import Dict
import Env
import Model.Config as Config exposing (Config)
import Model.Page as Page exposing (..)
import Model.PostForm as PostForm exposing (PostForm)
import Regex
import String.Extra
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing (..)


routes cfg =
    oneOf
        [ oneOf [ top, s "threads" ]
            |> map (Index <| Loading ())
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> map
                (NewThread
                    (PostForm.empty
                        |> PostForm.setSubj ""
                        >> PostForm.setLimits cfg.limits
                    )
                )
        , oneOf [ int, s "threads" </> int ]
            |> map (\tID -> Thread (Loading tID))
        ]


route : Config -> Url -> Page
route cfg =
    replacePathWithFragment
        >> parse (routes cfg)
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
