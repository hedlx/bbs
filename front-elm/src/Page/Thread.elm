module Page.Thread exposing
    ( Msg
    , State
    , Thread
    , decoder
    , equal
    , init
    , mapMessages
    , replyTo
    , subject
    , threadID
    , update
    , view
    )

import Alert
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Http
import Json.Decode as Decode
import List.Extra exposing (updateIf)
import Page.Response as Response
import Post exposing (Post)
import Post.Reply as Reply
import PostForm exposing (PostForm)
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Url.Builder



-- Model


type State
    = Loading PostForm Int
    | Idle PostForm Thread


type alias Thread =
    { id : Int
    , subject : Maybe String
    , messages : List Post
    }


type Msg
    = GotThread (Result Http.Error Thread)
    | PostFormMsg PostForm.Msg
    | MediaClicked Int String
    | ReplyToClicked Int Int


init _ tID =
    ( Loading PostForm.init tID, getThread tID )


path tID =
    [ "threads", String.fromInt tID ]


subject state =
    case state of
        Loading _ _ ->
            Nothing

        Idle _ thread ->
            thread.subject


threadID state =
    case state of
        Loading _ id ->
            id

        Idle _ thread ->
            thread.id


replyForm state =
    case state of
        Loading form _ ->
            form

        Idle form _ ->
            form


equal threadA threadB =
    threadID threadA == threadID threadB


mapReplyForm f state =
    case state of
        Loading form tID ->
            Loading (f form) tID

        Idle form thread ->
            Idle (f form) thread


mapMessages postNo f thread =
    { thread | messages = List.Extra.updateIf (.no >> (==) postNo) f thread.messages }


replyTo limits postNo =
    mapReplyForm
        (\form ->
            if postNo == 0 then
                PostForm.autofocus form

            else
                form
                    |> PostForm.setText limits (PostForm.text form ++ ">>" ++ String.fromInt postNo)
                    >> PostForm.autofocus
        )


toggleMediaPreview postNo mediaID state =
    case state of
        Loading _ _ ->
            state

        Idle form thread ->
            let
                newMessages =
                    updateIf (.no >> (==) postNo) (Post.toggleMediaPreview mediaID) thread.messages
            in
            Idle form { thread | messages = newMessages }


decoder tID =
    Decode.map2 (Thread tID)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "messages" <| Decode.list Post.decoder)


getThread tID =
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "threads", String.fromInt tID ] []
        , expect = Http.expectJson GotThread (decoder tID)
        }


focusReplyForm form =
    Cmd.map PostFormMsg (PostForm.focus form)



-- Update


update cfg msg state =
    case msg of
        PostFormMsg subMsg ->
            case state of
                Loading _ _ ->
                    Response.Ok state Cmd.none

                Idle form thread ->
                    case updatePostForm (threadID state) cfg.limits subMsg form of
                        PostForm.Ok newForm newCmd ->
                            Response.Ok (Idle newForm thread) (Cmd.map PostFormMsg newCmd)

                        PostForm.Err alert newForm ->
                            Response.Failed alert (Idle newForm thread) Cmd.none

                        PostForm.Submitted _ ->
                            Response.Ok (Idle (PostForm.disable PostForm.init) thread) (getThread (threadID state))

        GotThread (Ok thread) ->
            let
                currentReplyForm =
                    replyForm state

                cmdFocusForm =
                    if PostForm.isAutofocus currentReplyForm then
                        focusReplyForm currentReplyForm

                    else
                        Cmd.none
            in
            Response.Ok (Idle (PostForm.enable currentReplyForm) thread) cmdFocusForm

        GotThread (Err error) ->
            Response.Err (Alert.fromHttpError error)

        MediaClicked postNo mediaID ->
            Response.Ok (toggleMediaPreview postNo mediaID state) Cmd.none

        ReplyToClicked tID postNo ->
            if tID == threadID state then
                Response.Ok (replyTo cfg.limits postNo state) (focusReplyForm (replyForm state))

            else
                Response.ReplyTo tID postNo


updatePostForm tID =
    PostForm.update (path tID)



-- View


view cfg state =
    case state of
        Loading _ _ ->
            Spinner.view cfg.theme 256

        Idle form thread ->
            viewThread cfg form thread


viewThread cfg form thread =
    div
        [ -- This id is required to get scrolling manipulations working
          id "page-content"
        , Style.content
        ]
    <|
        [ viewSubject cfg.theme thread ]
            ++ viewPosts cfg thread
            ++ [ viewReplyForm cfg form ]


viewSubject theme thread =
    let
        style =
            classes [ T.f2, T.mt2, T.mb3, T.fw5, theme.fgThreadSubject ]

        strSubject =
            Maybe.withDefault
                ("Thread #" ++ String.fromInt thread.id)
                thread.subject
    in
    h1 [ style ] [ text strSubject ]


postMsg =
    { onMediaClicked = \_ -> MediaClicked
    , onReplyToClicked = ReplyToClicked
    }


viewPosts cfg { id, messages } =
    List.map (Html.Lazy.lazy4 Reply.view postMsg cfg id) messages


viewReplyForm cfg form =
    Html.map PostFormMsg <|
        div [ class T.mt4 ] [ PostForm.view cfg.theme cfg.limits form ]
