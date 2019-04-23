module PostForm exposing
    ( Msg
    , PostForm
    , Response(..)
    , appendToText
    , autofocus
    , disable
    , empty
    , enable
    , focus
    , isAutofocus
    , setSubj
    , text
    , update
    , view
    )

import Alert exposing (Alert)
import Attachment exposing (Attachment)
import Browser.Dom as Dom
import Env
import File exposing (File)
import File.Select as Select
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Http
import Json.Encode as Encode
import Keyboard
import Keyboard.Events
import Limits exposing (Limits)
import PostForm.Attachments as Attachments exposing (Attachments)
import Spinner
import Style
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Task
import Theme exposing (Theme)
import Url.Builder



-- Model


type PostForm
    = PostForm PostForm_


type alias PostForm_ =
    { isEnabled : Bool
    , isAutofocus : Bool
    , name : String
    , trip : String
    , pass : String
    , subj : Maybe String
    , text : String
    , attachments : Attachments
    }


empty : PostForm
empty =
    PostForm
        { isEnabled = True
        , isAutofocus = False
        , name = ""
        , trip = ""
        , pass = ""
        , subj = Nothing
        , text = ""
        , attachments = Attachments.empty
        }


isEmpty : PostForm -> Bool
isEmpty (PostForm form) =
    String.isEmpty form.text
        && String.isEmpty form.pass


isTextBlank : PostForm -> Bool
isTextBlank (PostForm form) =
    String.isEmpty (String.trim form.text)


isValid : PostForm -> Bool
isValid postForm =
    not (isTextBlank postForm)
        || not (List.isEmpty <| attachments postForm)


isEnabled : PostForm -> Bool
isEnabled (PostForm form) =
    form.isEnabled


isAutofocus : PostForm -> Bool
isAutofocus (PostForm form) =
    form.isAutofocus


hasAttachments : PostForm -> Bool
hasAttachments (PostForm form) =
    not (Attachments.isEmpty form.attachments)


name : PostForm -> String
name (PostForm form) =
    form.name


trip : PostForm -> String
trip (PostForm form) =
    form.trip


pass : PostForm -> String
pass (PostForm form) =
    form.pass


subj : PostForm -> Maybe String
subj (PostForm form) =
    form.subj


text : PostForm -> String
text (PostForm form) =
    form.text


attachments : PostForm -> List Attachment
attachments (PostForm form) =
    Attachments.toList form.attachments


notUploadedAttachments : PostForm -> List Attachment
notUploadedAttachments (PostForm form) =
    Attachments.toList form.attachments
        |> List.filter (\rec -> rec.backendID == Nothing)


disable : PostForm -> PostForm
disable (PostForm form) =
    PostForm { form | isEnabled = False }


enable : PostForm -> PostForm
enable (PostForm form) =
    PostForm { form | isEnabled = True }


autofocus : PostForm -> PostForm
autofocus (PostForm form) =
    PostForm { form | isAutofocus = True }


setName : Limits -> String -> PostForm -> PostForm
setName limits newName (PostForm form) =
    PostForm { form | name = limitString limits.maxLenName <| String.trimLeft newName }


setTrip : String -> PostForm -> PostForm
setTrip newTrip (PostForm form) =
    PostForm { form | trip = String.trim newTrip }


setPass : String -> PostForm -> PostForm
setPass newPass (PostForm form) =
    PostForm { form | pass = String.trim newPass }


setSubj : Limits -> String -> PostForm -> PostForm
setSubj limits newSubj (PostForm form) =
    PostForm { form | subj = Just (limitString limits.maxLenSubj <| String.trimLeft newSubj) }


setText : Limits -> String -> PostForm -> PostForm
setText limits newText (PostForm form) =
    PostForm { form | text = limitString limits.maxLenText newText }


appendToText : Limits -> String -> PostForm -> PostForm
appendToText limits str (PostForm form) =
    PostForm { form | text = limitString limits.maxLenText (form.text ++ str) }


addFiles : List File -> PostForm -> ( PostForm, Cmd Msg )
addFiles files (PostForm form) =
    let
        ( newAttachments, cmdGeneratePreviews ) =
            Attachments.add PreviewGenerated files form.attachments
    in
    ( PostForm { form | attachments = newAttachments }, cmdGeneratePreviews )


setPreview : Attachment.ID -> Attachment.Preview -> PostForm -> PostForm
setPreview attachID preview (PostForm form) =
    PostForm
        { form
            | attachments =
                Attachments.updateAttachment attachID
                    (Attachment.updatePreview preview)
                    form.attachments
        }


setBackendID : Attachment.ID -> Attachment.BackendID -> PostForm -> PostForm
setBackendID attachID backendID (PostForm form) =
    PostForm
        { form
            | attachments =
                Attachments.updateAttachment attachID
                    (Attachment.updateBackendID backendID)
                    form.attachments
        }


removeAttachment : Attachment.ID -> PostForm -> PostForm
removeAttachment attachID (PostForm form) =
    PostForm { form | attachments = Attachments.remove attachID form.attachments }


limitString : Maybe Int -> String -> String
limitString maybeLimit str =
    maybeLimit
        |> Maybe.map (\maxLen -> String.left maxLen str)
        >> Maybe.withDefault str


countChars : PostForm -> Int
countChars (PostForm form) =
    String.length <| form.text


countWords : PostForm -> Int
countWords (PostForm form) =
    let
        words =
            String.words (String.trim form.text)
                |> List.filter isWord
    in
    List.length words


isWord : String -> Bool
isWord str =
    not (String.isEmpty str)


focus : PostForm -> Cmd Msg
focus _ =
    Dom.focus "post-form-text" |> Task.attempt (\_ -> NoOp)


submit : List String -> PostForm -> Cmd Msg
submit submitPath postForm =
    Http.post
        { url = Url.Builder.crossOrigin Env.urlAPI submitPath []
        , body = Http.jsonBody (toJson postForm)
        , expect = Http.expectWhatever FormSubmitted
        }


toJson : PostForm -> Encode.Value
toJson (PostForm form) =
    let
        fixedName =
            if String.isEmpty (String.trim form.name) then
                Env.defaultName

            else
                String.trim form.name

        formSubjOrEmpty =
            form.subj
                |> Maybe.map (\subjVal -> [ ( "subject", Encode.string subjVal ) ])
                >> Maybe.withDefault []
    in
    Encode.object <|
        [ ( "name", Encode.string fixedName )
        , ( "secret", Encode.string form.trip )
        , ( "password", Encode.string form.pass )
        , ( "text", Encode.string form.text )
        , ( "media", Attachments.encode form.attachments )
        ]
            ++ formSubjOrEmpty



-- Update


type Msg
    = NoOp
    | NameChanged String
    | TripChanged String
    | PassChanged String
    | SubjChanged String
    | TextChanged String
    | SelectFiles
    | FilesSelected File (List File)
    | PreviewGenerated Int String
    | RemoveFile Int
    | Unfocus String
    | Submit
    | FormSubmitted (Result Http.Error ())
    | AttachmentUploaded (Result Http.Error ( Int, String ))


type Response
    = Ok PostForm (Cmd Msg)
    | Err Alert PostForm
    | Submitted PostForm


update : List String -> Limits -> Msg -> PostForm -> Response
update submitPath limits msg postForm =
    case msg of
        NoOp ->
            Ok postForm Cmd.none

        NameChanged newVal ->
            Ok (setName limits newVal postForm) Cmd.none

        TripChanged newVal ->
            Ok (setTrip newVal postForm) Cmd.none

        PassChanged newVal ->
            Ok (setPass newVal postForm) Cmd.none

        SubjChanged newVal ->
            Ok (setSubj limits newVal postForm) Cmd.none

        TextChanged newVal ->
            Ok (setText limits newVal postForm) Cmd.none

        SelectFiles ->
            Ok postForm (Select.files Env.fileFormats FilesSelected)

        FilesSelected file moreFiles ->
            let
                selectedFiles =
                    file :: moreFiles

                ( newPostForm, cmdGeneratePreviews ) =
                    addFiles selectedFiles postForm
            in
            Ok newPostForm cmdGeneratePreviews

        PreviewGenerated attachID preview ->
            Ok (setPreview attachID preview postForm) Cmd.none

        RemoveFile attachID ->
            Ok (removeAttachment attachID postForm) Cmd.none

        Unfocus id ->
            Ok postForm (Dom.blur id |> Task.attempt (\_ -> NoOp))

        Submit ->
            let
                uploadCmds =
                    notUploadedAttachments postForm
                        |> List.map (Attachment.upload AttachmentUploaded)

                cmd =
                    if List.isEmpty uploadCmds then
                        submit submitPath postForm

                    else
                        Cmd.batch uploadCmds
            in
            Ok (disable postForm) cmd

        FormSubmitted result ->
            case result of
                Result.Err httpError ->
                    Err (Alert.fromHttpError httpError) (enable postForm)

                Result.Ok () ->
                    Submitted postForm

        AttachmentUploaded result ->
            case result of
                Result.Err httpError ->
                    Err (Alert.fromHttpError httpError) (enable postForm)

                Result.Ok ( attachID, backendID ) ->
                    let
                        newPostForm =
                            setBackendID attachID backendID postForm

                        cmd =
                            if List.isEmpty (notUploadedAttachments newPostForm) then
                                submit submitPath newPostForm

                            else
                                Cmd.none
                    in
                    Ok newPostForm cmd



-- View


view : Theme -> Limits -> PostForm -> Html Msg
view theme limits form =
    let
        style =
            classes [ T.h_100, T.w_100, T.flex, T.flex_row ]
    in
    div [ style ]
        [ viewMeta theme limits form
        , viewPostBody theme form
        ]


viewMeta : Theme -> Limits -> PostForm -> Html Msg
viewMeta theme limits form =
    let
        style =
            classes [ T.pl2, T.pr3, T.mw5, T.flex, T.flex_column ]
    in
    div [ style ] <|
        viewNameInput theme form
            ++ viewTripInput theme form
            ++ viewPassInput theme form
            ++ [ viewSubmit theme form
               , viewProblems theme form
               , div [ class T.flex_grow_1 ] []
               ]
            ++ viewInfo limits form


viewNameInput : Theme -> PostForm -> List (Html Msg)
viewNameInput theme form =
    [ formLabel "Name"
    , input
        [ id "post-form-input"
        , unfocusOnEsc "post-form-input"
        , type_ "text"
        , value <| name form
        , styleTextInput theme
        , styleFormElement
        , onInput NameChanged
        , placeholder "Anonymous"
        ]
        []
    ]


viewTripInput : Theme -> PostForm -> List (Html Msg)
viewTripInput theme form =
    [ formLabel "Tripcode Secret"
    , input
        [ id "post-form-trip"
        , unfocusOnEsc "post-form-trip"
        , type_ "text"
        , value <| trip form
        , styleTextInput theme
        , styleFormElement
        , onInput TripChanged
        , disabled << not <| isEnabled form
        ]
        []
    ]


viewPassInput : Theme -> PostForm -> List (Html Msg)
viewPassInput theme form =
    [ formLabel "Password"
    , input
        [ id "post-form-pass"
        , unfocusOnEsc "post-form-pass"
        , type_ "password"
        , value <| pass form
        , styleTextInput theme
        , styleFormElement
        , onInput PassChanged
        , disabled << not <| isEnabled form
        ]
        []
    ]


viewPostBody : Theme -> PostForm -> Html Msg
viewPostBody theme form =
    let
        style =
            classes [ T.pl3, T.flex_grow_1, T.flex, T.flex_column ]
    in
    div [ style ] <|
        viewPostSubj theme form
            ++ viewPostComment theme form
            ++ viewAttachments theme form


viewPostSubj : Theme -> PostForm -> List (Html Msg)
viewPostSubj theme form =
    case subj form of
        Just subjVal ->
            [ formLabel "Subject"
            , input
                [ id "post-form-subj"
                , unfocusOnEsc "post-form-subj"
                , type_ "text"
                , value subjVal
                , styleFormElement
                , styleTextInput theme
                , onInput SubjChanged
                , disabled << not <| isEnabled form
                ]
                []
            ]

        Nothing ->
            []


viewAttachments : Theme -> PostForm -> List (Html Msg)
viewAttachments theme form =
    [ formLabel "Attached Images"
    , div [ classes [ T.flex, T.justify_center ], styleFormElement ] <|
        List.map (viewAttachment theme) (attachments form)
            ++ [ viewButtonSelectAttachments theme form ]
    ]


viewAttachment : Theme -> Attachment -> Html Msg
viewAttachment theme { id, preview } =
    let
        previewImg base64Img =
            div
                [ styleFormMediaPreview
                , Html.Attributes.style "background-image" <| String.concat [ "url('", base64Img, "')" ]
                , onClick <| RemoveFile id
                ]
                [ overlay ]

        overlay =
            div [ styleOverlay, Html.Attributes.style "visibility" "none" ]
                [ div [] [ Html.text "Click to Remove" ] ]

        styleOverlay =
            classes
                [ T.absolute
                , T.h_100
                , T.w_100
                , T.pl3
                , T.pr3
                , T.flex
                , T.justify_center
                , T.flex_column
                , T.tc
                , T.child
                , T.bg_black_70
                ]
    in
    Maybe.map previewImg preview
        |> Maybe.withDefault (viewPreviewLoadingSpinner theme)


viewPreviewLoadingSpinner : Theme -> Html Msg
viewPreviewLoadingSpinner theme =
    div [ styleFormMediaPreview ] [ Spinner.view theme 64 ]


viewButtonSelectAttachments : Theme -> PostForm -> Html Msg
viewButtonSelectAttachments theme _ =
    let
        style =
            classes [ T.b__dashed, T.pa3, T.tc, T.br1, T.bw1, T.bg_transparent, theme.fgPost, theme.bInput ]
    in
    div
        [ style
        , Style.flexFill
        , Style.buttonEnabled
        , onClick SelectFiles
        ]
        [ div [ Tachyons.classes [ T.h_100, T.flex, T.flex_column, T.justify_center ] ]
            [ div [] [ Html.text "Add Images" ] ]
        ]


viewPostComment : Theme -> PostForm -> List (Html Msg)
viewPostComment theme form =
    let
        style =
            classes [ T.flex_grow_1, T.pa1, T.br1, T.b__solid, T.bw1, T.w_100, theme.fgInput, theme.bgInput, theme.bInput ]
    in
    [ formLabel "Comment"
    , textarea
        [ id "post-form-text"
        , unfocusOnEsc "post-form-text"
        , value <| text form
        , style
        , styleFormElement
        , onInput TextChanged
        , Html.Attributes.style "resize" "none"
        , disabled << not <| isEnabled form
        ]
        []
    ]


viewSubmit : Theme -> PostForm -> Html Msg
viewSubmit theme form =
    let
        disabledAttrs =
            if isValid form && isEnabled form then
                [ disabled False
                , Style.buttonEnabled
                , classes [ theme.fgButton, theme.bgButton ]
                ]

            else
                [ disabled True
                , classes [ theme.fgButtonDisabled, theme.bgButtonDisabled ]
                ]
    in
    button
        ([ onClick Submit
         , Style.textButton theme
         , styleFromButton
         , styleFormElement
         ]
            ++ disabledAttrs
        )
        [ Html.text "Post" ]


viewProblems : Theme -> PostForm -> Html Msg
viewProblems theme form =
    let
        textCantBeBlank =
            formProblem theme "Post should have a comment or an attachment."
                |> viewIf
                    (isTextBlank form
                        && not (hasAttachments form)
                    )
    in
    div [ class T.h3 ] [ textCantBeBlank ]


viewInfo : Limits -> PostForm -> List (Html Msg)
viewInfo limits form =
    let
        strMaxLenText =
            limits
                |> .maxLenText
                >> Maybe.map String.fromInt
                >> Maybe.withDefault "..."
    in
    [ formInfo
        "Symbols"
        (String.fromInt (countChars form)
            ++ " / "
            ++ strMaxLenText
        )
    , formInfo "Words" (String.fromInt (countWords form))
    ]


formProblem : Theme -> String -> Html Msg
formProblem theme str =
    div [ styleFormElement, classes [ theme.fgAlert ] ] [ Html.text str ]


formLabel : String -> Html Msg
formLabel str =
    label [ styleFormElement ] [ Html.text str ]


formInfo : String -> String -> Html Msg
formInfo strLabel strVal =
    div [ styleFormElement ] [ Html.text <| strLabel ++ ": ", Html.text strVal ]


styleTextInput : Theme -> Attribute Msg
styleTextInput theme =
    classes [ T.pa1, T.br1, T.b__solid, theme.fgInput, theme.bgInput, theme.bInput ]


styleFormElement : Attribute Msg
styleFormElement =
    classes [ T.db, T.mb3, T.w_100 ]


styleFormMediaPreview : Attribute Msg
styleFormMediaPreview =
    classes [ T.h4, T.w4, T.mr2, T.relative, T.hide_child, T.pointer, T.overflow_hidden, T.br1, T.cover, T.bg_center ]


styleFromButton : Attribute Msg
styleFromButton =
    classes [ T.mt3, T.mb4 ]


unfocusOnEsc : String -> Attribute Msg
unfocusOnEsc elemID =
    Keyboard.Events.on Keyboard.Events.Keydown [ ( Keyboard.Escape, Unfocus elemID ) ]
