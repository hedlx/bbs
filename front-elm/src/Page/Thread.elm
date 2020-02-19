module Page.Thread exposing
    ( Msg
    , State
    , Thread
    , decoder
    , init
    , initGoTo
    , initReplyTo
    , reInit
    , replyTo
    , route
    , subject
    , threadID
    , update
    , updatePost
    , view
    )

import Alert
import Config exposing (Config)
import DomCmd
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
import Route exposing (Route)
import Route.CrossPage
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Url.Builder


init : Config -> ID -> ( State, Cmd Msg )
init cfg id =
    ( Loading PostForm.empty id, getThread cfg id Nothing )


reInit : Config -> State -> ( State, Cmd Msg )
reInit cfg state =
    case state of
        Loading _ id ->
            ( state, getThread cfg id Nothing )

        LoadingPost _ id postNo ->
            ( state, getThread cfg id (Just postNo) )

        Idle _ thread ->
            init cfg thread.id


initGoTo : Config -> Int -> Int -> Maybe State -> ( State, Cmd Msg )
initGoTo cfg id postNo maybeThread =
    case maybeThread of
        Just (Idle form thread) ->
            if thread.id == id then
                ( Idle form { thread | focusedPostNo = Just postNo }
                , DomCmd.scrollTo (always NoOp) 100 60 (Post.domID thread.id postNo)
                )

            else
                ( LoadingPost PostForm.empty id postNo, getThread cfg id (Just postNo) )

        _ ->
            ( LoadingPost PostForm.empty id postNo, getThread cfg id (Just postNo) )


initReplyTo : Config -> Int -> Int -> ( State, Cmd Msg )
initReplyTo cfg id postNo =
    let
        state =
            Loading PostForm.empty id
                |> replyTo cfg.limits postNo
    in
    ( state, Cmd.none )



-- MODEL


type State
    = Loading PostForm Int
    | LoadingPost PostForm Int Int
    | Idle PostForm Thread


type alias Thread =
    { id : ID
    , focusedPostNo : Maybe ID
    , subject : Maybe String
    , messages : List Post
    }


type alias ID =
    Int


route : State -> Route
route state =
    Route.Thread (threadID state)


pathPost : ID -> List String
pathPost tID =
    [ "threads", String.fromInt tID ]


subject : State -> Maybe String
subject state =
    case state of
        Idle _ thread ->
            thread.subject

        _ ->
            Nothing


threadID : State -> ID
threadID state =
    case state of
        Loading _ id ->
            id

        LoadingPost _ id _ ->
            id

        Idle _ thread ->
            thread.id


postForm : State -> PostForm
postForm state =
    case state of
        Loading form _ ->
            form

        LoadingPost form _ _ ->
            form

        Idle form _ ->
            form


mapPostForm : (PostForm -> PostForm) -> State -> State
mapPostForm f state =
    case state of
        Loading form tID ->
            Loading (f form) tID

        LoadingPost form tID pID ->
            LoadingPost (f form) tID pID

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
                    |> PostForm.appendToText limits ("@" ++ String.fromInt postNo ++ "\n")
                    >> PostForm.autofocus
        )


toggleMediaPreview : Post.No -> Media.ID -> State -> State
toggleMediaPreview postNo mediaID state =
    case state of
        Idle form thread ->
            let
                newMessages =
                    updateIf (.no >> (==) postNo) (Post.toggleMediaPreview mediaID) thread.messages
            in
            Idle form { thread | messages = newMessages }

        _ ->
            state


decoder : ID -> Maybe ID -> Decoder Thread
decoder tID maybePostNo =
    Decode.map2 (Thread tID maybePostNo)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "messages" <| Decode.list Post.decoder)


getThread : Config -> ID -> Maybe ID -> Cmd Msg
getThread { urlApi } tID maybePostNo =
    Http.get
        { url = Url.Builder.crossOrigin urlApi [ "threads", String.fromInt tID ] []
        , expect = Http.expectJson GotThread (decoder tID maybePostNo)
        }



-- UPDATE


type Msg
    = NoOp
    | GotThread (Result Http.Error Thread)
    | PostFormMsg PostForm.Msg
    | MediaClicked Int String
    | ReplyToClicked Int Int
    | FilesDropped (List File)


update : Config -> Msg -> State -> Response State Msg
update cfg msg state =
    case msg of
        NoOp ->
            Response.None

        PostFormMsg subMsg ->
            case state of
                Idle form thread ->
                    updatePostForm (threadID state) cfg subMsg form
                        |> handlePostFormResponse cfg thread

                _ ->
                    Response.None

        GotThread (Ok thread) ->
            let
                currentPostForm =
                    postForm state
            in
            Response.return (Idle (PostForm.enable currentPostForm) thread)
                |> Response.andThenIf (PostForm.isAutofocus currentPostForm) focusPostForm
                |> Response.andThenIf (thread.focusedPostNo /= Nothing) (scrollToPost 350)

        GotThread (Err error) ->
            Response.raise (Alert.fromHttpError error)

        MediaClicked postNo mediaID ->
            Response.return (toggleMediaPreview postNo mediaID state)

        ReplyToClicked tID postNo ->
            if tID == threadID state then
                Response.return (replyTo cfg.limits postNo state)
                    |> Response.andThen focusPostForm

            else
                Response.CrossPage (Route.CrossPage.ReplyTo tID postNo)

        FilesDropped files ->
            case state of
                Idle form thread ->
                    PostForm.addFiles cfg.limits files form
                        |> handlePostFormResponse cfg thread
                        >> Response.andThen focusPostForm

                _ ->
                    Response.None


updatePostForm : ID -> Config -> PostForm.Msg -> PostForm -> PostForm.Response
updatePostForm tID =
    PostForm.update (pathPost tID)


handlePostFormResponse : Config -> Thread -> PostForm.Response -> Response State Msg
handlePostFormResponse cfg thread postFormResponse =
    case postFormResponse of
        PostForm.Ok newForm newCmd ->
            Response.Ok (Idle newForm thread) (Cmd.map PostFormMsg newCmd) Alert.None

        PostForm.Err alert newForm ->
            Response.Ok (Idle newForm thread) Cmd.none (Alert.map PostFormMsg alert)

        PostForm.Submitted _ ->
            Response.Ok (Idle (PostForm.disable PostForm.empty) thread)
                (getThread cfg thread.id Nothing)
                Alert.None


focusPostForm : State -> Response State Msg
focusPostForm state =
    case state of
        Idle form _ ->
            Response.Ok state (Cmd.map PostFormMsg (PostForm.focus form)) Alert.None

        _ ->
            Response.return state


scrollToPost : Int -> State -> Response State Msg
scrollToPost speed state =
    case state of
        Idle _ thread ->
            case thread.focusedPostNo of
                Just postNo ->
                    Response.Ok state
                        (DomCmd.scrollTo (always NoOp) 100 speed (Post.domID thread.id postNo))
                        Alert.None

                Nothing ->
                    Response.return state

        _ ->
            Response.return state



-- VIEW


view : Config -> State -> Html Msg
view cfg state =
    case state of
        Idle form thread ->
            viewThread cfg form thread

        _ ->
            Spinner.view cfg.theme 256


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
            classes [ T.f3, T.f2_ns, T.mt2, T.mb3, T.fw5, theme.fgThreadSubject ]

        strSubject =
            Maybe.withDefault
                ("Thread #" ++ String.fromInt thread.id)
                thread.subject
    in
    header [] [ h1 [ style ] [ text strSubject ] ]


postEventHandlers : Post.EventHandlers Msg {}
postEventHandlers =
    { onMediaClicked = always MediaClicked
    , onReplyToClicked = ReplyToClicked
    }


viewPosts : Config -> Thread -> List (Html Msg)
viewPosts cfg { id, messages, focusedPostNo } =
    List.map (Html.Lazy.lazy4 viewPost cfg id focusedPostNo) messages


viewPost : Config -> Int -> Maybe Int -> Post -> Html Msg
viewPost cfg id focusedPostNo post =
    case focusedPostNo of
        Just postNo ->
            Post.view postEventHandlers cfg id (post.no == postNo) post

        Nothing ->
            Post.view postEventHandlers cfg id False post


viewPostForm : Config -> PostForm -> Html Msg
viewPostForm cfg form =
    Html.map PostFormMsg <|
        div [ classes [ T.mt4, T.pr1 ] ] [ PostForm.view cfg form ]
