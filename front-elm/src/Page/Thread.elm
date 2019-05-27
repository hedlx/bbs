module Page.Thread exposing
    ( Msg
    , State
    , Thread
    , decoder
    , init
    , replyTo
    , subject
    , threadID
    , update
    , updatePost
    , view
    )

import Alert
import Config exposing (Config)
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Extra exposing (..)
import Html.Lazy
import Http
import Json.Decode as Decode exposing (Decoder)
import Limits exposing (Limits)
import List.Extra exposing (updateIf)
import Media
import Page.Response as Response exposing (Response)
import Post exposing (Post)
import PostForm exposing (PostForm)
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Url.Builder


init : ID -> ( State, Cmd Msg )
init tID =
    ( Loading PostForm.empty tID, getThread tID )



-- Model


type State
    = Loading PostForm Int
    | Idle PostForm Thread


type alias Thread =
    { id : ID
    , subject : Maybe String
    , messages : List Post
    }


type alias ID =
    Int


type Msg
    = GotThread (Result Http.Error Thread)
    | PostFormMsg PostForm.Msg
    | MediaClicked Int String
    | ReplyToClicked Int Int


path : ID -> List String
path tID =
    [ "threads", String.fromInt tID ]


subject : State -> Maybe String
subject state =
    case state of
        Loading _ _ ->
            Nothing

        Idle _ thread ->
            thread.subject


threadID : State -> ID
threadID state =
    case state of
        Loading _ id ->
            id

        Idle _ thread ->
            thread.id


replyForm : State -> PostForm
replyForm state =
    case state of
        Loading form _ ->
            form

        Idle form _ ->
            form


mapReplyForm : (PostForm -> PostForm) -> State -> State
mapReplyForm f state =
    case state of
        Loading form tID ->
            Loading (f form) tID

        Idle form thread ->
            Idle (f form) thread


updatePost : Post.No -> (Post -> Post) -> Thread -> Thread
updatePost postNo f thread =
    { thread | messages = List.Extra.updateIf (.no >> (==) postNo) f thread.messages }


replyTo : Limits -> Post.No -> State -> State
replyTo limits postNo =
    mapReplyForm
        (\form ->
            if postNo == 0 then
                PostForm.autofocus form

            else
                form
                    |> PostForm.appendToText limits (">>" ++ String.fromInt postNo)
                    >> PostForm.autofocus
        )


toggleMediaPreview : Post.No -> Media.ID -> State -> State
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


decoder : ID -> Decoder Thread
decoder tID =
    Decode.map2 (Thread tID)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "messages" <| Decode.list Post.decoder)


getThread : ID -> Cmd Msg
getThread tID =
    Http.get
        { url = Url.Builder.crossOrigin Env.urlAPI [ "threads", String.fromInt tID ] []
        , expect = Http.expectJson GotThread (decoder tID)
        }



-- Update


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        PostFormMsg subMsg ->
            case state of
                Loading _ _ ->
                    Response.Ok state Cmd.none

                Idle form thread ->
                    case updatePostForm (threadID state) cfg subMsg form of
                        PostForm.Ok newForm newCmd ->
                            Response.Ok (Idle newForm thread) (Cmd.map PostFormMsg newCmd)

                        PostForm.Err alert newForm ->
                            Response.Failed (Alert.map PostFormMsg alert) (Idle newForm thread) Cmd.none

                        PostForm.Submitted _ ->
                            Response.Ok (Idle (PostForm.disable PostForm.empty) thread) (getThread (threadID state))

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


updatePostForm : ID -> Config -> PostForm.Msg -> PostForm -> PostForm.Response
updatePostForm tID =
    PostForm.update (path tID)


focusReplyForm : PostForm -> Cmd Msg
focusReplyForm form =
    Cmd.map PostFormMsg (PostForm.focus form)



-- View


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Loading _ _ ->
            Spinner.view cfg.theme 256

        Idle form thread ->
            viewThread cfg form thread


viewThread : Config -> PostForm -> Thread -> Html Msg
viewThread cfg form thread =
    section
        [ -- This id is required to get scrolling manipulations working
          id "page-content"
        , Style.content
        ]
    <|
        [ viewSubject cfg.theme thread ]
            ++ viewPosts cfg thread
            ++ [ viewReplyForm cfg form ]


viewSubject : Theme -> Thread -> Html Msg
viewSubject theme thread =
    let
        style =
            classes [ T.f2, T.mt2, T.mb3, T.fw5, theme.fgThreadSubject ]

        strSubject =
            Maybe.withDefault
                ("Thread #" ++ String.fromInt thread.id)
                thread.subject
    in
    header [] [ h1 [ style ] [ text strSubject ] ]


postEventHandlers : Post.EventHandlers Msg
postEventHandlers =
    { onMediaClicked = \_ -> MediaClicked
    , onReplyToClicked = ReplyToClicked
    }


viewPosts : Config -> Thread -> List (Html Msg)
viewPosts cfg { id, messages } =
    List.map (Html.Lazy.lazy4 Post.view postEventHandlers cfg id) messages


viewReplyForm : Config -> PostForm -> Html Msg
viewReplyForm cfg form =
    Html.map PostFormMsg <|
        div [ classes [ T.mt4, T.pr2, T.pr0_ns ] ] [ PostForm.view cfg form ]
