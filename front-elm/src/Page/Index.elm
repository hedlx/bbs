module Page.Index exposing (Msg, State, decoder, init, update, view)

import Alert
import Config exposing (Config)
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Http
import Json.Decode as Decode
import List.Extra exposing (updateIf)
import Page.Response as Response
import Post as Post exposing (Post)
import Post.Op as Op
import Post.Reply as Reply
import Spinner
import Style
import Tachyons.Classes as TC
import Url.Builder



-- Model


type State
    = Loading
    | Idle (List ThreadPreview)


type alias ThreadPreview =
    { id : Int
    , subject : Maybe String
    , op : Post
    , last : List Post
    }


type Msg
    = GotThreads (Result Http.Error State)
    | MediaClicked Int Int String
    | ReplyToClicked Int Int


postMsg =
    { onMediaClicked = MediaClicked
    , onReplyToClicked = ReplyToClicked
    }


init =
    ( Loading, getThreads )


mapLast postNo f threadPw =
    { threadPw | last = updateIf (.no >> (==) postNo) f threadPw.last }


decoder =
    Decode.map (Idle << List.reverse) (Decode.list decoderThreadPreview)


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


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Idle threads ->
            div [ Style.content, id "page-content" ] <|
                List.map (viewThreadPreview cfg) threads

        Loading ->
            Spinner.view cfg.theme 256


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


toggleMediaPreviewThread postNo mediaID threadPw =
    if postNo == 0 then
        { threadPw | op = Post.toggleMediaPreview mediaID threadPw.op }

    else
        mapLast postNo (Post.toggleMediaPreview mediaID) threadPw


viewThreadPreview cfg threadPw =
    div []
        [ Op.view postMsg cfg threadPw
        , viewLast cfg threadPw
        ]


viewLast cfg { id, last } =
    if List.isEmpty last then
        nothing

    else
        div [ class TC.pl5 ] <|
            List.map (Reply.view postMsg cfg id) last
