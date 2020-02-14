module Page exposing
    ( Msg
    , Page
    , ResponseToModel
    , changeRoute
    , notFound
    , route
    , title
    , update
    , view
    )

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
import Route.CrossPage exposing (CrossPage)
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Url exposing (Url)


changeRoute : Config -> Url -> Page -> ( Page, Cmd Msg )
changeRoute cfg url (Page page) =
    let
        route_ =
            Route.parse url
    in
    if page.isCrossPageRedirect then
        case ( route_, page.state ) of
            ( Route.Index query, Index state ) ->
                mapInitPage Index IndexMsg (Index.reInit cfg query state)

            ( Route.Thread tID, Thread state ) ->
                if tID == Thread.threadID state then
                    mapInitPage Thread ThreadMsg (Thread.reInit cfg state)

                else
                    changeRoute cfg url (return page.state)

            _ ->
                changeRoute cfg url (return page.state)

    else
        case route_ of
            Route.NotFound ->
                ( notFound, Cmd.none )

            Route.Index query ->
                mapInitPage Index IndexMsg (Index.init cfg query)

            Route.Thread threadID ->
                mapInitPage Thread ThreadMsg (Thread.init cfg threadID)

            Route.Post threadID postID ->
                mapInitPage Thread ThreadMsg (Thread.initGoTo cfg threadID postID)

            Route.NewThread ->
                mapInitPage NewThread NewThreadMsg NewThread.init


mapInitPage : (subState -> State) -> (msg -> Msg) -> ( subState, Cmd msg ) -> ( Page, Cmd Msg )
mapInitPage toState toMsg ( subState, cmd ) =
    ( return (toState subState), Cmd.map toMsg cmd )



-- MODEL


type Page
    = Page
        { isCrossPageRedirect : Bool
        , state : State
        }


return : State -> Page
return state =
    Page
        { isCrossPageRedirect = False
        , state = state
        }


returnCrossPage : State -> Page
returnCrossPage state =
    Page
        { isCrossPageRedirect = True
        , state = state
        }


type State
    = NotFound
    | Index Index.State
    | Thread Thread.State
    | NewThread NewThread.State


notFound : Page
notFound =
    return NotFound


title : Page -> String
title (Page page) =
    case page.state of
        NotFound ->
            "Not Found"

        NewThread _ ->
            "New Thread"

        Thread state ->
            Thread.subject state
                |> Maybe.withDefault ("Thread #" ++ String.fromInt (Thread.threadID state))

        Index _ ->
            ""


route : Page -> Maybe Route
route (Page page) =
    case page.state of
        NewThread state ->
            Just (NewThread.route state)

        Index state ->
            Just (Index.route state)

        Thread state ->
            Just (Thread.route state)

        NotFound ->
            Nothing



-- UPDATE


type Msg
    = IndexMsg Index.Msg
    | NewThreadMsg NewThread.Msg
    | ThreadMsg Thread.Msg
    | ReturnToIndex


type alias ResponseToModel =
    ( Page, Cmd Msg, Alert Msg )


update : Config -> Msg -> Page -> ResponseToModel
update cfg msg page =
    case msg of
        ReturnToIndex ->
            Response.redirect cfg Route.index
                |> handleResponse cfg page

        _ ->
            updatePage cfg msg page
                |> handleResponse cfg page


updatePage : Config -> Msg -> Page -> Response Page Msg
updatePage cfg msg (Page page) =
    case ( msg, page.state ) of
        ( IndexMsg subMsg, Index state ) ->
            Index.update cfg subMsg state
                |> Response.map2 (return << Index) IndexMsg

        ( NewThreadMsg subMsg, NewThread state ) ->
            NewThread.update cfg subMsg state
                |> Response.map2 (return << NewThread) NewThreadMsg

        ( ThreadMsg subMsg, Thread state ) ->
            Thread.update cfg subMsg state
                |> Response.map2 (return << Thread) ThreadMsg

        _ ->
            Response.return (Page page)


handleResponse : Config -> Page -> Response Page Msg -> ResponseToModel
handleResponse cfg page reponse =
    case reponse of
        Response.None ->
            ( page, Cmd.none, Alert.None )

        Response.Ok newPage cmd alert ->
            ( newPage, cmd, alert )

        Response.Command cmd alert ->
            ( page, cmd, alert )

        Response.Err cmd alert ->
            ( page, cmd, alert )

        Response.CrossPage crossPage ->
            handleCrossPage cfg crossPage


handleCrossPage : Config -> CrossPage -> ResponseToModel
handleCrossPage cfg crossPage =
    case crossPage of
        Route.CrossPage.IndexLastThread numPage ->
            let
                ( newState, cmd ) =
                    Index.initLoadAndScrollToLastThread
            in
            ( returnCrossPage (Index newState)
            , Cmd.batch
                [ Route.go cfg.key (Route.indexPage numPage)
                , Cmd.map IndexMsg cmd
                ]
            , Alert.None
            )

        Route.CrossPage.ReplyTo tID postNo ->
            let
                ( newState, cmd ) =
                    Thread.initReplyTo cfg tID postNo
            in
            ( returnCrossPage (Thread newState)
            , Cmd.batch
                [ Route.go cfg.key (Route.Thread tID)
                , Cmd.map ThreadMsg cmd
                ]
            , Alert.None
            )



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
viewContent cfg (Page page) =
    case page.state of
        Index state ->
            Html.map IndexMsg (Index.view cfg state)

        Thread state ->
            Html.map ThreadMsg (Thread.view cfg state)

        NewThread state ->
            Html.map NewThreadMsg (NewThread.view cfg state)

        NotFound ->
            viewNotFound cfg.theme


viewNotFound : Theme -> Html Msg
viewNotFound theme =
    let
        stylePage =
            classes [ T.flex, T.flex_column, T.justify_center ]

        styleNotFound =
            classes [ T.f2, T.tc ]
    in
    div [ Style.content, stylePage ]
        [ h1 [ styleNotFound ]
            [ text "Page Not Found" ]
        , button
            [ onClick ReturnToIndex
            , Style.buttonEnabled theme
            , Style.textButton theme
            , classes
                [ theme.fgButton
                , theme.bgButton
                , T.w4
                , T.center
                ]
            ]
            [ text "Return to Index" ]
        ]
