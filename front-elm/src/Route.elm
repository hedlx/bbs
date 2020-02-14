module Route exposing
    ( QueryIndex
    , Route(..)
    , go
    , index
    , indexPage
    , isIndex
    , link
    , parse
    )

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Builder as Builder exposing (QueryParameter)
import Url.Parser as Parser exposing ((</>), (<?>), Parser, int, oneOf, s, top)
import Url.Parser.Query as Query


type Route
    = NotFound
    | Index QueryIndex
    | Thread Int
    | Post Int Int
    | NewThread


type alias QueryIndex =
    { page : Maybe Int }


encodeQueryIndex : QueryIndex -> List QueryParameter
encodeQueryIndex query =
    List.filterMap identity
        [ Maybe.map (Builder.int "page") query.page ]


index : Route
index =
    indexWithQuery Nothing


indexPage : Int -> Route
indexPage numPage =
    indexWithQuery (Just numPage)


isIndex : Route -> Bool
isIndex route =
    case route of
        Index _ ->
            True

        _ ->
            False


indexWithQuery : Maybe Int -> Route
indexWithQuery =
    Index << QueryIndex


parser : Parser (Route -> Route) Route
parser =
    oneOf
        [ oneOf [ top </> s "404", s "threads" </> s "404" ]
            |> Parser.map NotFound
        , oneOf [ top <?> Query.int "page", s "threads" <?> Query.int "page" ]
            |> Parser.map indexWithQuery
        , oneOf [ int, s "threads" </> int ]
            |> Parser.map Thread
        , oneOf [ int </> int, s "threads" </> int </> int ]
            |> Parser.map Post
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> Parser.map NewThread
        ]


parse : Url -> Route
parse url =
    Parser.parse parser url
        |> Maybe.map assertRoute
        >> Maybe.withDefault NotFound


assertRoute : Route -> Route
assertRoute route =
    case route of
        Index { page } ->
            if Maybe.map ((>) 0) page == Just True then
                NotFound

            else
                route

        _ ->
            route


link : Route -> String
link route =
    Builder.relative ("#" :: path route) (queryParameters route)


path : Route -> List String
path route =
    case route of
        NotFound ->
            [ "404" ]

        Index _ ->
            []

        Thread threadID ->
            [ String.fromInt threadID ]

        Post threadID postID ->
            [ String.fromInt threadID, String.fromInt postID ]

        NewThread ->
            [ "new" ]


queryParameters : Route -> List Builder.QueryParameter
queryParameters route =
    case route of
        Index query ->
            encodeQueryIndex query

        _ ->
            []


go : Nav.Key -> Route -> Cmd msg
go key route =
    Nav.pushUrl key (link route)
