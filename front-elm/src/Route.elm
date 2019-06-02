module Route exposing (QueryIndex, QueryThread, Route(..), index, indexPage, link, parse, replyTo, thread)

import Url exposing (Url)
import Url.Builder as Builder exposing (QueryParameter)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, oneOf, s, top)
import Url.Parser.Query as Query


type Route
    = Index QueryIndex
    | Thread Int QueryThread
    | NewThread


type alias QueryIndex =
    { page : Maybe Int }


encodeQueryIndex : QueryIndex -> List QueryParameter
encodeQueryIndex query =
    List.filterMap identity
        [ Maybe.map (Builder.int "page") query.page ]


type alias QueryThread =
    { replyTo : Maybe Int }


encodeQueryThread : QueryThread -> List QueryParameter
encodeQueryThread query =
    List.filterMap identity
        [ Maybe.map (Builder.int "replyTo") query.replyTo ]


index : Route
index =
    indexWithQuery Nothing


indexPage : Int -> Route
indexPage numPage =
    indexWithQuery (Just numPage)


indexWithQuery : Maybe Int -> Route
indexWithQuery =
    Index << QueryIndex


thread : Int -> Route
thread threadID =
    threadWithQuery threadID Nothing


replyTo : Int -> Int -> Route
replyTo threadID postID =
    threadWithQuery threadID (Just postID)


threadWithQuery : Int -> Maybe Int -> Route
threadWithQuery threadID qReplyTo =
    Thread threadID (QueryThread qReplyTo)


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ oneOf [ top <?> Query.int "page", s "threads" <?> Query.int "page" ]
            |> Parser.map indexWithQuery
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
        Index _ ->
            []

        Thread threadID _ ->
            [ String.fromInt threadID ]

        NewThread ->
            [ "new" ]


queryParameters : Route -> List Builder.QueryParameter
queryParameters route =
    case route of
        Index query ->
            encodeQueryIndex query

        Thread _ query ->
            encodeQueryThread query

        NewThread ->
            []
