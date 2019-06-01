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
import File exposing (File)
import FilesDrop
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
import Route exposing (QueryThread)
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Url.Builder


init : Config -> ID -> QueryThread -> ( State, Cmd Msg )
init cfg id query =
    ( Loading PostForm.empty id, getThread id )
        |> initReplyTo cfg query.replyTo


initReplyTo : Config -> Maybe Int -> ( State, Cmd Msg ) -> ( State, Cmd Msg )
initReplyTo cfg qReplyTo =
    case qReplyTo of
        Nothing ->
            identity

        Just postNo ->
            Tuple.mapFirst (replyTo cfg.limits postNo)



-- MODEL


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
    = NoOp
    | GotThread (Result Http.Error Thread)
    | PostFormMsg PostForm.Msg
    | MediaClicked Int String
    | ReplyToClicked Int Int
    | FilesDropped (List File)


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


postForm : State -> PostForm
postForm state =
    case state of
        Loading form _ ->
            form

        Idle form _ ->
            form


mapPostForm : (PostForm -> PostForm) -> State -> State
mapPostForm f state =
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
    mapPostForm
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



-- UPDATE


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        NoOp ->
            Response.None

        PostFormMsg subMsg ->
            case state of
                Idle form thread ->
                    updatePostForm (threadID state) cfg subMsg form
                        |> handlePostFormResponse thread

                Loading _ _ ->
                    Response.None

        GotThread (Ok thread) ->
            let
                currentPostForm =
                    postForm state
            in
            Response.return (Idle (PostForm.enable currentPostForm) thread)
                |> Response.andThenIf (PostForm.isAutofocus currentPostForm) focusPostForm

        GotThread (Err error) ->
            Response.raise (Alert.fromHttpError error)

        MediaClicked postNo mediaID ->
            Response.return (toggleMediaPreview postNo mediaID state)

        ReplyToClicked tID postNo ->
            if tID == threadID state then
                Response.return (replyTo cfg.limits postNo state)
                    |> Response.andThen focusPostForm

            else
                Response.redirect cfg (Route.replyTo tID postNo)

        FilesDropped files ->
            case state of
                Idle form thread ->
                    PostForm.addFiles cfg.limits files form
                        |> handlePostFormResponse thread
                        >> Response.andThen focusPostForm

                Loading _ _ ->
                    Response.None


updatePostForm : ID -> Config -> PostForm.Msg -> PostForm -> PostForm.Response
updatePostForm tID =
    PostForm.update (path tID)


handlePostFormResponse : Thread -> PostForm.Response -> Response State Msg
handlePostFormResponse thread postFormResponse =
    case postFormResponse of
        PostForm.Ok newForm newCmd ->
            Response.Ok (Idle newForm thread) (Cmd.map PostFormMsg newCmd) Alert.None

        PostForm.Err alert newForm ->
            Response.Ok (Idle newForm thread) Cmd.none (Alert.map PostFormMsg alert)

        PostForm.Submitted _ ->
            Response.Ok (Idle (PostForm.disable PostForm.empty) thread) (getThread thread.id) Alert.None


focusPostForm : State -> Response State Msg
focusPostForm state =
    case state of
        Idle form _ ->
            Response.Ok state (Cmd.map PostFormMsg (PostForm.focus form)) Alert.None

        _ ->
            Response.return state



-- VIEW


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
        , FilesDrop.onDragOver NoOp
        , FilesDrop.onDrop FilesDropped
        ]
    <|
        [ viewSubject cfg.theme thread ]
            ++ viewPosts cfg thread
            ++ [ viewPostForm cfg form ]


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


viewPostForm : Config -> PostForm -> Html Msg
viewPostForm cfg form =
    Html.map PostFormMsg <|
        div [ classes [ T.mt4 ] ] [ PostForm.view cfg form ]
