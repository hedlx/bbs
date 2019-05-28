module Page exposing (Msg(..), Page(..), route, title, update, urlParser, view)

import Alert exposing (Alert)
import Browser.Navigation as Nav
import Config exposing (Config)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Index as Index
import Page.NewThread as NewThread
import Page.Response as Response exposing (Response)
import Page.Thread as Thread
import Route
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)



-- Model


type Page
    = NotFound
    | Index Index.State
    | NewThread NewThread.State
    | Thread Thread.State


type alias PageAndCmd =
    ( Page, Cmd Msg )


type alias ParserPage =
    Parser (PageAndCmd -> PageAndCmd) PageAndCmd


type alias ResponseToModel =
    ( Page, Cmd Msg, Alert Msg )


title : Page -> String
title page =
    case page of
        NotFound ->
            "NotFound"

        NewThread _ ->
            "New Thread"

        Thread state ->
            Thread.subject state
                |> Maybe.withDefault ("Thread #" ++ String.fromInt (Thread.threadID state))

        Index _ ->
            ""


equal : Page -> Page -> Bool
equal pageA pageB =
    case ( pageA, pageB ) of
        ( Thread threadA, Thread threadB ) ->
            Thread.threadID threadA == Thread.threadID threadB

        ( Index _, Index _ ) ->
            True

        ( NewThread _, NewThread _ ) ->
            True

        ( NotFound, NotFound ) ->
            True

        _ ->
            False


route : Page -> Url -> PageAndCmd
route page url =
    let
        ( pageRoute, cmdRoute ) =
            Parser.parse urlParser url
                |> Maybe.withDefault ( NotFound, Cmd.none )
    in
    if equal page pageRoute then
        ( page, Cmd.none )

    else
        ( pageRoute, cmdRoute )


urlParser : ParserPage
urlParser =
    oneOf
        [ oneOf [ top, s "threads" ]
            |> Parser.map (mapPageInit Index IndexMsg <| Index.init)
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> Parser.map (mapPageInit NewThread NewThreadMsg <| NewThread.init)
        , oneOf [ int, s "threads" </> int ]
            |> Parser.map (mapPageInit Thread ThreadMsg << Thread.init)
        ]


type alias InjPage a =
    a -> Page


type alias InjMsg msg =
    msg -> Msg


mapPageInit : InjPage a -> InjMsg msg -> ( a, Cmd msg ) -> PageAndCmd
mapPageInit toPage toMsg ( statePage, cmdPage ) =
    ( toPage statePage, Cmd.map toMsg cmdPage )



-- Update


type Msg
    = IndexMsg Index.Msg
    | NewThreadMsg NewThread.Msg
    | ThreadMsg Thread.Msg


update : Config -> Msg -> Page -> ResponseToModel
update cfg msg page =
    updatePage cfg msg page
        |> handleResponse cfg page


updatePage : Config -> Msg -> Page -> Response Page Msg
updatePage cfg msg page =
    case ( msg, page ) of
        ( IndexMsg subMsg, Index state ) ->
            Index.update cfg subMsg state
                |> Response.map2 Index IndexMsg

        ( NewThreadMsg subMsg, NewThread state ) ->
            NewThread.update cfg subMsg state
                |> Response.map2 NewThread NewThreadMsg

        ( ThreadMsg subMsg, Thread state ) ->
            Thread.update cfg subMsg state
                |> Response.map2 Thread ThreadMsg

        _ ->
            Response.Ok page Cmd.none


handleResponse : Config -> Page -> Response Page Msg -> ResponseToModel
handleResponse cfg currentPage reponse =
    case reponse of
        Response.None ->
            ( currentPage, Cmd.none, Alert.None )

        Response.Ok newPage cmdPage ->
            ( newPage, cmdPage, Alert.None )

        Response.Failed alert newPage cmdPage ->
            ( newPage, cmdPage, alert )

        Response.Err alert ->
            ( currentPage, Cmd.none, alert )

        Response.Redirect path ->
            ( currentPage, Nav.pushUrl cfg.key (Route.internalLink path), Alert.None )

        Response.ReplyTo tID postNo ->
            let
                ( pageThread, pageCmd ) =
                    Thread.init tID
                        |> Tuple.mapFirst (Thread.replyTo cfg.limits postNo)

                cmdReplaceUrl =
                    Nav.replaceUrl cfg.key (Route.internalLink [ String.fromInt tID ])
            in
            ( Thread pageThread
            , Cmd.batch [ cmdReplaceUrl, Cmd.map ThreadMsg pageCmd ]
            , Alert.None
            )



-- View


view : Config -> Page -> Html Msg
view cfg page =
    let
        theme =
            cfg.theme

        style =
            classes [ T.w_100, T.min_vh_100, theme.bg, theme.fg, theme.font ]
    in
    div [ style ] [ viewContent cfg page ]


viewContent : Config -> Page -> Html Msg
viewContent cfg page =
    case page of
        Index state ->
            Html.map IndexMsg (Index.view cfg state)

        Thread state ->
            Html.map ThreadMsg (Thread.view cfg state)

        NewThread state ->
            Html.map NewThreadMsg (NewThread.view cfg state)

        NotFound ->
            viewNotFound


viewNotFound : Html Msg
viewNotFound =
    let
        stylePage =
            classes [ T.flex, T.flex_column, T.justify_center ]

        styleNotFound =
            classes [ T.f1, T.tc ]
    in
    h1 [ Style.content, stylePage ]
        [ div [ styleNotFound ]
            [ text "Page Not Found" ]
        ]
