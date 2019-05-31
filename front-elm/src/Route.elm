module Route exposing (Route(..), internalLink, parse)

import String.Extra
import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)


type Route
    = Index
    | Thread Int
    | NewThread


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ oneOf [ top, s "threads" ]
            |> Parser.map Index
        , oneOf [ int, s "threads" </> int ]
            |> Parser.map Thread
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> Parser.map NewThread
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser url


internalLink : List String -> String
internalLink ls =
    let
        fixedPath =
            List.concatMap (String.split "/") ls
                |> List.filter (not << String.Extra.isBlank)
    in
    Builder.relative ("#" :: fixedPath) []
