module Page exposing (Msg(..), Page(..), init, title, update, view)

import Alert exposing (Alert)
import Config exposing (Config)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.Index as Index
import Page.NewThread as NewThread
import Page.Response as Response exposing (Response)
import Page.Thread as Thread
import Route exposing (Route)
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Url exposing (Url)


init : Config -> Url -> ( Page, Cmd Msg )
init cfg url =
    Route.parse url
        |> Maybe.map (initFromRoute cfg)
        >> Maybe.withDefault ( NotFound, Cmd.none )


initFromRoute : Config -> Route -> ( Page, Cmd Msg )
initFromRoute cfg route =
    case route of
        Route.Index query ->
            mapInitPage Index IndexMsg (Index.init cfg query)

        Route.Thread threadID query ->
            mapInitPage Thread ThreadMsg (Thread.init cfg threadID query)

        Route.NewThread ->
            mapInitPage NewThread NewThreadMsg NewThread.init


mapInitPage : (page -> Page) -> (msg -> Msg) -> ( page, Cmd msg ) -> ( Page, Cmd Msg )
mapInitPage toPage toMsg ( page, cmd ) =
    ( toPage page, Cmd.map toMsg cmd )



-- MODEL


type Page
    = NotFound
    | Index Index.State
    | Thread Thread.State
    | NewThread NewThread.State


title : Page -> String
title page =
    case page of
        NotFound ->
            "Not Found"

        NewThread _ ->
            "New Thread"

        Thread state ->
            Thread.subject state
                |> Maybe.withDefault ("Thread #" ++ String.fromInt (Thread.threadID state))

        Index _ ->
            ""



-- UPDATE


type Msg
    = IndexMsg Index.Msg
    | NewThreadMsg NewThread.Msg
    | ThreadMsg Thread.Msg


type alias ResponseToModel =
    ( Page, Cmd Msg, Alert Msg )


update : Config -> Msg -> Page -> ResponseToModel
update cfg msg page =
    updatePage cfg msg page
        |> handleResponse page


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
            Response.Ok page Cmd.none Alert.None


handleResponse : Page -> Response Page Msg -> ResponseToModel
handleResponse currentPage reponse =
    case reponse of
        Response.None ->
            ( currentPage, Cmd.none, Alert.None )

        Response.Ok newPage cmd alert ->
            ( newPage, cmd, alert )

        Response.Err cmd alert ->
            ( currentPage, cmd, alert )



-- VIEW


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
