module Page exposing (Msg(..), Page(..), route, title, update, urlParser, view)

import Alert exposing (Alert)
import Browser.Navigation as Nav
import Config exposing (Config)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Icons
import Page.Index as Index
import Page.NewThread as NewThread
import Page.Response as Response exposing (Response)
import Page.Thread as Thread
import Route
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as TC
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, int, oneOf, s, top)



-- Model


type Page
    = NotFound
    | Index Index.State
    | NewThread NewThread.State
    | Thread Thread.State


type Msg
    = IndexMsg Index.Msg
    | NewThreadMsg NewThread.Msg
    | ThreadMsg Thread.Msg


type alias PageAndCmd =
    ( Page, Cmd Msg )


type alias ParserPage =
    Parser (PageAndCmd -> PageAndCmd) PageAndCmd


type alias InjPage a =
    a -> Page


type alias InjMsg msg =
    msg -> Msg


type alias ResponseToModel =
    ( Page, Cmd Msg, List Alert )


route : Config -> Page -> Url -> PageAndCmd
route cfg page url =
    let
        ( routePage, routeCmd ) =
            Parser.parse (urlParser cfg) url
                |> Maybe.withDefault ( NotFound, Cmd.none )
    in
    case ( page, routePage ) of
        ( Thread currentThread, Thread routeThread ) ->
            if Thread.equal currentThread routeThread then
                ( page, Cmd.none )

            else
                ( routePage, routeCmd )

        _ ->
            ( routePage, routeCmd )


urlParser : Config -> ParserPage
urlParser cfg =
    oneOf
        [ oneOf [ top, s "threads" ]
            |> Parser.map (mapPageInit Index IndexMsg <| Index.init)
        , oneOf [ s "new", s "threads" </> s "new" ]
            |> Parser.map (mapPageInit NewThread NewThreadMsg <| NewThread.init cfg)
        , oneOf [ int, s "threads" </> int ]
            |> Parser.map (mapPageInit Thread ThreadMsg << Thread.init cfg)
        ]


mapPageInit : InjPage a -> InjMsg msg -> ( a, Cmd msg ) -> PageAndCmd
mapPageInit toPage toMsg ( statePage, cmdPage ) =
    ( toPage statePage, Cmd.map toMsg cmdPage )


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



-- Update


update : Config -> Msg -> Page -> ResponseToModel
update cfg msg page =
    updatePage cfg msg page
        |> handleResponse cfg page


updatePage : Config -> Msg -> Page -> Response Page Msg
updatePage cfg msg page =
    case ( msg, page ) of
        ( IndexMsg subMsg, Index state ) ->
            Index.update cfg subMsg state
                |> Response.map Index IndexMsg

        ( NewThreadMsg subMsg, NewThread state ) ->
            NewThread.update cfg subMsg state
                |> Response.map NewThread NewThreadMsg

        ( ThreadMsg subMsg, Thread state ) ->
            Thread.update cfg subMsg state
                |> Response.map Thread ThreadMsg

        _ ->
            Response.Ok page Cmd.none


handleResponse : Config -> Page -> Response Page Msg -> ResponseToModel
handleResponse cfg currentPage reponse =
    case reponse of
        Response.Ok newPage cmdPage ->
            ( newPage, cmdPage, [] )

        Response.Failed alert newPage cmdPage ->
            ( newPage, cmdPage, [ alert ] )

        Response.Err alert ->
            ( currentPage, Cmd.none, [ alert ] )

        Response.Redirect path ->
            ( currentPage, Nav.pushUrl cfg.key ("#/" ++ String.join "/" path), [] )

        Response.ReplyTo tID postNo ->
            let
                ( pageThread, pageCmd ) =
                    Thread.init cfg tID
                        |> Tuple.mapFirst (Thread.replyTo cfg.limits postNo)

                cmdReplaceUrl =
                    Nav.replaceUrl cfg.key ("#/" ++ String.fromInt tID)
            in
            ( Thread pageThread
            , Cmd.batch [ cmdReplaceUrl, Cmd.map ThreadMsg pageCmd ]
            , []
            )



-- View


view : Config -> Page -> Html Msg
view cfg page =
    let
        theme =
            cfg.theme

        style =
            classes [ TC.w_100, TC.min_vh_100, theme.bg, theme.fg, theme.font ]
    in
    div [ style ]
        [ viewMenu cfg
        , viewContent cfg page
        ]


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


viewMenu cfg =
    let
        theme =
            cfg.theme

        style =
            classes
                [ TC.fixed
                , TC.pa0
                , TC.fl
                , TC.h_100
                , TC.w3
                , TC.flex
                , TC.flex_column
                , TC.items_center
                , theme.bgMenu
                ]
    in
    div [ style ]
        [ btnIndex theme
        , btnNewThread theme
        , btnDelete theme cfg
        , div [ Style.flexFiller ] []
        , btnSettings theme cfg
        ]


btnIndex theme =
    a [ href <| Route.internalLink [] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Style.buttonEnabled theme
            , Html.Attributes.title "Main Page"
            ]
            [ Icons.hedlx ]
        ]


btnNewThread theme =
    a [ href <| Route.internalLink [ "new" ] ]
        [ div
            [ styleButtonMenu
            , Style.buttonIconic
            , Style.buttonEnabled theme
            , Html.Attributes.title "Start New Thread"
            ]
            [ Icons.add ]
        ]


btnDelete theme _ =
    let
        isEnabled =
            False

        dynamicAttrs =
            if isEnabled then
                [ Style.buttonEnabled theme
                , Html.Attributes.title "Delete"
                ]

            else
                [ Style.buttonDisabled theme
                , Html.Attributes.title "Delete\nYou need to select items before"
                ]
    in
    div ([ styleButtonMenu, Style.buttonIconic, Style.buttonDisabled theme ] ++ dynamicAttrs) [ Icons.delete ]


btnSettings theme _ =
    div
        [ styleButtonMenu
        , Style.buttonIconic
        , Style.buttonEnabled theme
        , Html.Attributes.title "Settings"
        ]
        [ Icons.settings ]


viewNotFound =
    let
        stylePage =
            classes [ TC.flex, TC.flex_column, TC.justify_center ]

        styleNotFound =
            classes [ TC.f1, TC.tc ]
    in
    h1 [ Style.content, stylePage ]
        [ div [ styleNotFound ]
            [ text "Page Not Found" ]
        ]


styleButtonMenu =
    class TC.pa3
