module Page.Index exposing (Msg, State, decoder, init, update, view)

import Alert
import Config exposing (Config)
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Extra exposing (updateIf)
import Media
import Page.Response as Response exposing (Response)
import Post exposing (Post)
import Spinner
import Style
import Tachyons.Classes as T
import Url.Builder


init : ( State, Cmd Msg )
init =
    ( Loading, getThreads )



-- Model


type State
    = Loading
    | Idle (List ThreadPreview)


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


decoder : Decoder State
decoder =
    Decode.map (Idle << List.reverse) (Decode.list decoderThreadPreview)


decoderThreadPreview : Decoder ThreadPreview
decoderThreadPreview =
    Decode.map4 ThreadPreview
        (Decode.field "id" Decode.int)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)


getThreads : Cmd Msg
getThreads =
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "threads" ] []
        , expect = Http.expectJson GotThreads decoder
        }



-- Update


type Msg
    = GotThreads (Result Http.Error State)
    | MediaClicked ThreadID Post.No Media.ID
    | ReplyToClicked ThreadID Post.No


update : Config -> Msg -> State -> Response State Msg
update _ msg state =
    case msg of
        GotThreads (Ok newState) ->
            Response.Ok newState Cmd.none

        GotThreads (Err error) ->
            Response.Err (Alert.fromHttpError error)

        MediaClicked tID postNo mediaID ->
            Response.Ok (toggleMediaPreview tID postNo mediaID state) Cmd.none

        ReplyToClicked tID postNo ->
            Response.ReplyTo tID postNo



-- View


postEventHandlers : Post.EventHandlers Msg
postEventHandlers =
    { onMediaClicked = MediaClicked
    , onReplyToClicked = ReplyToClicked
    }


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Idle threads ->
            div [ Style.content, id "page-content" ] <|
                List.map (viewThreadPreview cfg) threads

        Loading ->
            Spinner.view cfg.theme 256


toggleMediaPreview : ThreadID -> Post.No -> Media.ID -> State -> State
toggleMediaPreview tID postNo mediaID state =
    case state of
        Loading ->
            Loading

        Idle threadPws ->
            let
                newThreadPreviews =
                    updateIf
                        (.id >> (==) tID)
                        (toggleMediaPreviewThread postNo mediaID)
                        threadPws
            in
            Idle newThreadPreviews


toggleMediaPreviewThread : Post.No -> Media.ID -> ThreadPreview -> ThreadPreview
toggleMediaPreviewThread postNo mediaID threadPw =
    if postNo == 0 then
        { threadPw | op = Post.toggleMediaPreview mediaID threadPw.op }

    else
        mapLast postNo (Post.toggleMediaPreview mediaID) threadPw


viewThreadPreview : Config -> ThreadPreview -> Html Msg
viewThreadPreview cfg threadPw =
    section []
        [ Post.viewOp postEventHandlers cfg (toOp threadPw)
        , viewLast cfg threadPw
        ]


viewLast : Config -> ThreadPreview -> Html Msg
viewLast cfg { id, last } =
    if List.isEmpty last then
        nothing

    else
        section [ class T.pl5 ] <|
            List.map (Post.view postEventHandlers cfg id) last
