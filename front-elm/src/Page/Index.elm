module Page.Index exposing
    ( Msg
    , State
    , init
    , initLoadAndScrollToLastThread
    , reInit
    , route
    , update
    , view
    )

import Alert
import Browser.Dom as Dom
import Config exposing (Config)
import DomCmd
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Extra exposing (updateIf)
import Media
import Page.Response as Response exposing (Response)
import Post exposing (Post)
import Route exposing (QueryIndex, Route)
import Route.CrossPage
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Task
import Theme exposing (Theme)
import Url.Builder


init : Config -> QueryIndex -> ( State, Cmd Msg )
init cfg query =
    ( Loading, cmdInit cfg query )


initLoadAndScrollToLastThread : ( State, Cmd Msg )
initLoadAndScrollToLastThread =
    ( LoadingScrollToLastThread, Cmd.none )


reInit : Config -> QueryIndex -> State -> ( State, Cmd Msg )
reInit cfg query state =
    ( state, cmdInit cfg query )


cmdInit : Config -> QueryIndex -> Cmd Msg
cmdInit { perPageThreads } query =
    let
        numPage =
            Maybe.withDefault 0 query.page

        perPage =
            Config.perPageToInt perPageThreads
                |> Maybe.withDefault Env.threadsPerPage
    in
    getThreads perPage numPage



-- MODEL


type State
    = Loading
    | LoadingScrollToLastThread
    | Idle Page


type alias Page =
    { number : Int
    , totalThreads : Int
    , threads : List ThreadPreview
    }


type alias ThreadPreview =
    { id : ThreadID
    , subject : Maybe String
    , op : Post
    , last : List Post
    }


type alias ThreadID =
    Int


route : State -> Route
route state =
    case state of
        Idle { number } ->
            Route.indexPage number

        _ ->
            Route.index


toOp : ThreadPreview -> Post.Op
toOp { id, subject, op } =
    { threadID = id
    , subject = subject
    , post = op
    }


mapLast : Post.No -> (Post -> Post) -> ThreadPreview -> ThreadPreview
mapLast postNo f threadPw =
    { threadPw | last = updateIf (.no >> (==) postNo) f threadPw.last }


decoderPage : Int -> Decoder Page
decoderPage numPage =
    Decode.map2 (Page numPage)
        (Decode.field "count" Decode.int)
        (Decode.field "threads" decoderThreads)


decoderThreads : Decoder (List ThreadPreview)
decoderThreads =
    Decode.map List.reverse (Decode.list decoderThreadPreview)


decoderThreadPreview : Decoder ThreadPreview
decoderThreadPreview =
    Decode.map4 ThreadPreview
        (Decode.field "id" Decode.int)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)


getThreads : Int -> Int -> Cmd Msg
getThreads perPageThreads numPage =
    let
        params =
            [ Url.Builder.int "offset" (perPageThreads * numPage)
            , Url.Builder.int "limit" perPageThreads
            ]
    in
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "threads" ] params
        , expect = Http.expectJson GotThreads (decoderPage numPage)
        }


getNextThreadID : ThreadID -> Page -> Maybe ThreadID
getNextThreadID tID page =
    List.map .id page.threads
        |> List.Extra.dropWhile ((/=) tID)
        >> List.tail
        >> Maybe.andThen List.head


getPrevThreadID : ThreadID -> Page -> Maybe ThreadID
getPrevThreadID tID page =
    List.map .id page.threads
        |> List.Extra.takeWhile ((/=) tID)
        >> List.Extra.last


getFirstOpPostPosition : List ThreadPreview -> (Float -> Msg) -> Cmd Msg
getFirstOpPostPosition threads toMsg =
    let
        getElementResultToMsg result =
            case result of
                Ok data ->
                    toMsg data.element.y

                Err _ ->
                    NoOp

        cmdGetElement threadPw =
            Dom.getElement (Post.opDomID threadPw.id)
    in
    List.head threads
        |> Maybe.map cmdGetElement
        >> Maybe.map (Task.attempt getElementResultToMsg)
        >> Maybe.withDefault Cmd.none


cmdScrollToLastThread : Page -> Cmd Msg
cmdScrollToLastThread page =
    List.Extra.last page.threads
        |> Maybe.map .id
        >> Maybe.map (\tID -> getFirstOpPostPosition page.threads (ScrollTo (Post.opDomID tID)))
        >> Maybe.withDefault Cmd.none



-- UPDATE


type Msg
    = NoOp
    | GotThreads (Result Http.Error Page)
    | ToggleMediaPreview ThreadID Post.No Media.ID
    | ReplyTo ThreadID Post.No
    | GoToNextThread ThreadID
    | GoToPrevThread ThreadID
    | ChangePage Int
    | ScrollTo String Float


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        NoOp ->
            Response.None

        GotThreads (Ok newPage) ->
            handleGotThreads cfg newPage state

        GotThreads (Err error) ->
            Response.raise (Alert.fromHttpError error)

        ToggleMediaPreview tID postNo mediaID ->
            Response.return (toggleMediaPreview tID postNo mediaID state)

        ReplyTo tID postNo ->
            Response.CrossPage (Route.CrossPage.ReplyTo tID postNo)

        GoToNextThread tID ->
            case state of
                Idle page ->
                    goToNearbyThread tID False cfg page

                _ ->
                    Response.None

        GoToPrevThread tID ->
            case state of
                Idle page ->
                    goToNearbyThread tID True cfg page

                _ ->
                    Response.None

        ChangePage numPage ->
            Response.redirect cfg (Route.indexPage numPage)

        ScrollTo domID offset ->
            Response.do <| DomCmd.scrollTo (always NoOp) (floor offset) 60 domID


handleGotThreads : Config -> Page -> State -> Response State Msg
handleGotThreads cfg newPage state =
    if newPage.number > 0 && List.isEmpty newPage.threads then
        Response.redirect cfg Route.NotFound

    else
        let
            newState =
                Idle newPage
        in
        case state of
            LoadingScrollToLastThread ->
                Response.Ok newState (cmdScrollToLastThread newPage) Alert.None

            _ ->
                Response.return newState


goToNearbyThread : Int -> Bool -> Config -> Page -> Response State Msg
goToNearbyThread threadID isGoToPrev cfg page =
    let
        maybeNearID =
            if isGoToPrev then
                getPrevThreadID threadID page

            else
                getNextThreadID threadID page
    in
    case maybeNearID of
        Nothing ->
            if isGoToPrev then
                Response.CrossPage (Route.CrossPage.IndexLastThread (page.number - 1))

            else
                Response.redirect cfg (Route.indexPage (page.number + 1))

        Just nearID ->
            Response.do <|
                getFirstOpPostPosition page.threads
                    (ScrollTo (Post.opDomID nearID))



-- VIEW


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Idle page ->
            div [ Style.content, id "page-content" ]
                [ viewThreads cfg page
                , viewPageControls cfg page
                ]

        _ ->
            Spinner.view cfg.theme 256


viewThreads : Config -> Page -> Html Msg
viewThreads cfg { number, totalThreads, threads } =
    let
        perPage =
            Config.perPageToInt cfg.perPageThreads
                |> Maybe.withDefault Env.threadsPerPage

        totalOffset =
            perPage * number
    in
    div []
        (List.intersperse (viewSeparator cfg.theme) <|
            List.indexedMap (viewThreadPreview cfg totalThreads totalOffset) threads
        )


viewSeparator : Theme -> Html Msg
viewSeparator theme =
    hr [ classes [ T.mt3, T.mb3, theme.bSeparator, T.bt_l, T.bb_0 ] ] []


postEventHandlers : Post.EventHandlersOP Msg
postEventHandlers =
    { onMediaClicked = ToggleMediaPreview
    , onReplyToClicked = ReplyTo
    , onNextThreadClicked = Just GoToNextThread
    , onPrevThreadClicked = Just GoToPrevThread
    }


viewThreadPreview : Config -> Int -> Int -> Int -> ThreadPreview -> Html Msg
viewThreadPreview cfg totalThreads totalOffset idx threadPw =
    let
        evHandlers =
            if totalOffset == 0 && idx == 0 then
                { postEventHandlers | onPrevThreadClicked = Nothing }

            else if idx + totalOffset + 1 == totalThreads then
                { postEventHandlers | onNextThreadClicked = Nothing }

            else
                postEventHandlers
    in
    section []
        [ Post.viewOp evHandlers cfg (toOp threadPw)
        , viewLast cfg threadPw
        ]


viewLast : Config -> ThreadPreview -> Html Msg
viewLast cfg { id, last } =
    if List.isEmpty last then
        nothing

    else
        section [ classes [ T.pl4_ns, T.pl5_l ] ] <|
            List.map (Post.view postEventHandlers cfg id False) last


viewPageControls : Config -> Page -> Html Msg
viewPageControls { theme, perPageThreads } { totalThreads, number } =
    let
        style =
            classes
                [ T.w_100
                , T.tc
                , T.mt3
                , T.mb1
                , T.mb3_ns
                , T.mt4_ns
                ]

        perPage =
            Config.perPageToInt perPageThreads
                |> Maybe.withDefault Env.threadsPerPage

        numPageLast =
            (totalThreads - 1) // perPage
    in
    div [ style ] <|
        [ viewPageBack theme number
        , viewPageLinks theme numPageLast number
        , viewPageNext theme numPageLast number
        ]


viewPageBack : Theme -> Int -> Html Msg
viewPageBack theme number =
    viewPageBtn
        theme
        (number > 0)
        (onClick (ChangePage (number - 1)))
        "← Back"


viewPageNext : Theme -> Int -> Int -> Html Msg
viewPageNext theme numPageLast number =
    viewPageBtn
        theme
        (number < numPageLast)
        (onClick (ChangePage (number + 1)))
        "Next →"


viewPageBtn : Theme -> Bool -> Attribute Msg -> String -> Html Msg
viewPageBtn theme isEnabled attrOnClick labelBtn =
    let
        attrs =
            if isEnabled then
                [ Style.buttonEnabled theme
                , attrOnClick
                , classes [ theme.fgButton, theme.bgButton ]
                ]

            else
                [ classes [ theme.fgButtonDisabled, theme.bgButtonDisabled ] ]
    in
    button (Style.textButton theme :: class T.ma1 :: attrs) [ text labelBtn ]


radiusNearPages : Int
radiusNearPages =
    2


viewPageLinks : Theme -> Int -> Int -> Html Msg
viewPageLinks theme numPageLast numPageCurrent =
    let
        viewPageBtn_ numPage =
            viewPageBtn
                theme
                (numPage /= numPageCurrent)
                (onClick (ChangePage numPage))
                (String.fromInt numPage)

        left =
            Basics.max 0 (numPageCurrent - radiusNearPages)

        right =
            Basics.min numPageLast (numPageCurrent + radiusNearPages)

        first =
            case left of
                0 ->
                    []

                1 ->
                    [ viewPageBtn_ 0 ]

                _ ->
                    [ viewPageBtn_ 0, text "..." ]

        last =
            case numPageLast - right of
                0 ->
                    []

                1 ->
                    [ viewPageBtn_ numPageLast ]

                _ ->
                    [ text "...", viewPageBtn_ numPageLast ]

        pages =
            List.range left right
    in
    div [ class T.dib_ns ] <|
        first
            ++ List.map viewPageBtn_ pages
            ++ last


toggleMediaPreview : ThreadID -> Post.No -> Media.ID -> State -> State
toggleMediaPreview tID postNo mediaID state =
    case state of
        Idle page ->
            let
                newThreads =
                    updateIf
                        (.id >> (==) tID)
                        (toggleMediaPreviewThread postNo mediaID)
                        page.threads
            in
            Idle { page | threads = newThreads }

        _ ->
            state


toggleMediaPreviewThread : Post.No -> Media.ID -> ThreadPreview -> ThreadPreview
toggleMediaPreviewThread postNo mediaID threadPw =
    if postNo == 0 then
        { threadPw | op = Post.toggleMediaPreview mediaID threadPw.op }

    else
        mapLast postNo (Post.toggleMediaPreview mediaID) threadPw
