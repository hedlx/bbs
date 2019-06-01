module Route exposing (QueryThread, Route(..), link, parse, replyTo, thread)

import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, oneOf, s, top)
import Url.Parser.Query as Query


type Route
    = Index
    | Thread Int QueryThread
    | NewThread


type alias QueryThread =
    { replyTo : Maybe Int }


encodeQueryThread : QueryThread -> List Builder.QueryParameter
encodeQueryThread query =
    List.filterMap identity
        [ Maybe.map (Builder.int "replyTo") query.replyTo ]


thread : Int -> Route
thread threadID =
    threadWithQuery threadID Nothing


replyTo : Int -> Int -> Route
replyTo threadID postID =
    threadWithQuery threadID (Just postID)


threadWithQuery : Int -> Maybe Int -> Route
threadWithQuery threadID qReplyTo =
    Thread threadID { replyTo = qReplyTo }


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ oneOf [ top, s "threads" ]
            |> Parser.map Index
        , oneOf [ int <?> Query.int "replyTo", s "threads" </> int <?> Query.int "replyTo" ]
            |> Parser.map threadWithQuery
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> Parser.map NewThread
        ]


parse : Url -> Maybe Route
parse url =
    Parser.parse parser url


link : Route -> String
link route =
    Builder.relative ("#" :: path route) (queryParameters route)


path : Route -> List String
path route =
    case route of
        Index ->
            []

        Thread threadID _ ->
            [ String.fromInt threadID ]

        NewThread ->
            [ "new" ]


queryParameters : Route -> List Builder.QueryParameter
queryParameters route =
    case route of
        Index ->
            []

        Thread _ query ->
            encodeQueryThread query

        NewThread ->
            []
