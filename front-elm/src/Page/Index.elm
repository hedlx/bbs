module Page.Index exposing (Msg, State, decoder, init, update, view)

import Alert
import Config exposing (Config)
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
import Route exposing (QueryIndex)
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Url.Builder


init : Config -> QueryIndex -> ( State, Cmd Msg )
init { perPage } query =
    let
        numPage =
            Maybe.withDefault 0 query.page
    in
    ( Loading, getThreads perPage numPage )



-- MODEL


type State
    = Loading
    | Idle TotalPages Page


type alias TotalPages =
    Int


type alias Page =
    { number : Int
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


toOp : ThreadPreview -> Post.Op
toOp { id, subject, op } =
    { threadID = id
    , subject = subject
    , post = op
    }


mapLast : Post.No -> (Post -> Post) -> ThreadPreview -> ThreadPreview
mapLast postNo f threadPw =
    { threadPw | last = updateIf (.no >> (==) postNo) f threadPw.last }


decoder : Int -> Decoder State
decoder numPage =
    Decode.map2 Idle
        (Decode.field "count" Decode.int)
        (Decode.field "threads" (decoderPage numPage))


decoderPage : Int -> Decoder Page
decoderPage numPage =
    Decode.map (Page numPage) decoderThreads


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
getThreads perPage numPage =
    let
        params =
            [ Url.Builder.int "offset" (perPage * numPage)
            , Url.Builder.int "limit" perPage
            ]
    in
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "threads" ] params
        , expect = Http.expectJson GotThreads (decoder numPage)
        }



-- UPDATE


type Msg
    = GotThreads (Result Http.Error State)
    | ToggleMediaPreview ThreadID Post.No Media.ID
    | ReplyTo ThreadID Post.No
    | ChangePage Int


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        GotThreads (Ok newState) ->
            Response.return newState

        GotThreads (Err error) ->
            Response.raise (Alert.fromHttpError error)

        ToggleMediaPreview tID postNo mediaID ->
            Response.return (toggleMediaPreview tID postNo mediaID state)

        ReplyTo tID postNo ->
            Response.redirect cfg (Route.replyTo tID postNo)

        ChangePage numPage ->
            Response.redirect cfg (Route.indexPage numPage)



-- VIEW


postEventHandlers : Post.EventHandlers Msg
postEventHandlers =
    { onMediaClicked = ToggleMediaPreview
    , onReplyToClicked = ReplyTo
    }


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Idle numPageLast { number, threads } ->
            div [ Style.content, id "page-content" ]
                [ viewThreads cfg threads
                , viewPageControls cfg numPageLast number
                ]

        Loading ->
            Spinner.view cfg.theme 256


viewThreads : Config -> List ThreadPreview -> Html Msg
viewThreads cfg threads =
    div [ classes [ T.pt3, T.pt0_ns ] ] <|
        List.map (viewThreadPreview cfg) threads


viewPageControls : Config -> Int -> Int -> Html Msg
viewPageControls { theme, perPage } totalThreads number =
    let
        style =
            classes
                [ T.w_100
                , T.tc
                , T.mt3
                , T.mb1
                , T.mb3_ns
                , T.mt0_ns
                ]

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



-- viewPrevPagesLinks theme number
-- ++ [ text (String.fromInt number) ]
-- ++ viewNextPagesLinks theme numPageLast number


toggleMediaPreview : ThreadID -> Post.No -> Media.ID -> State -> State
toggleMediaPreview tID postNo mediaID state =
    case state of
        Loading ->
            Loading

        Idle numPageLast page ->
            let
                newThreads =
                    updateIf
                        (.id >> (==) tID)
                        (toggleMediaPreviewThread postNo mediaID)
                        page.threads
            in
            Idle numPageLast { page | threads = newThreads }


toggleMediaPreviewThread : Post.No -> Media.ID -> ThreadPreview -> ThreadPreview
toggleMediaPreviewThread postNo mediaID threadPw =
    if postNo == 0 then
        { threadPw | op = Post.toggleMediaPreview mediaID threadPw.op }

    else
        mapLast postNo (Post.toggleMediaPreview mediaID) threadPw


viewThreadPreview : Config -> ThreadPreview -> Html Msg
viewThreadPreview cfg threadPw =
    let
        style =
            classes [ T.mb3, T.mb4_ns ]
    in
    section [ style ]
        [ Post.viewOp postEventHandlers cfg (toOp threadPw)
        , viewLast cfg threadPw
        ]


viewLast : Config -> ThreadPreview -> Html Msg
viewLast cfg { id, last } =
    if List.isEmpty last then
        nothing

    else
        section [ classes [ T.pl4_ns, T.pl5_l ] ] <|
            List.map (Post.view postEventHandlers cfg id) last
