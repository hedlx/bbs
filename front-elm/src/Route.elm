module Route exposing (internalLink)

import String.Extra
import Url.Builder as Builder
import Url.Parser exposing (..)


internalLink : List String -> String
internalLink ls =
    let
        fixedPath =
            List.concatMap (String.split "/") ls
                |> List.filter (not << String.Extra.isBlank)
    in
    Builder.relative ("#" :: fixedPath) []
