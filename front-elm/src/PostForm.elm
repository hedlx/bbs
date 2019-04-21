module PostForm exposing
    ( Msg
    , PostForm
    , ResultUpdate(..)
    , addFiles
    , autofocus
    , disable
    , empty
    , enable
    , focus
    , init
    , isAutofocus
    , isEmpty
    , isEnabled
    , name
    , setName
    , setPass
    , setSubj
    , setText
    , setTrip
    , subj
    , text
    , trip
    , update
    , view
    )

import Alert exposing (Alert)
import Attachment
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
import Tachyons.Classes as TC
import Task
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


type Msg
    = NoOp
    | NameChanged String
    | TripChanged String
    | PassChanged String
    | SubjChanged String
    | TextChanged String
    | SelectFiles
    | FilesSelected File (List File)
    | AttachmentPreviewGenerated Int String
    | RemoveFile Int
    | Unfocus String
    | Submit
    | FormSubmitted (Result Http.Error ())
    | FileUploaded (Result Http.Error ( Int, String ))


type ResultUpdate
    = Ok PostForm (Cmd Msg)
    | Err Alert PostForm
    | Submitted PostForm


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


isEmpty (PostForm form) =
    String.isEmpty form.text
        && String.isEmpty form.pass


isTextBlank (PostForm form) =
    String.isEmpty (String.trim form.text)


isValid postForm =
    not (isTextBlank postForm)
        || not (List.isEmpty <| files postForm)


hasAttachments (PostForm form) =
    not (Attachments.isEmpty form.attachments)


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


init =
    empty


isEnabled (PostForm form) =
    form.isEnabled


isAutofocus (PostForm form) =
    form.isAutofocus


name (PostForm form) =
    form.name


trip (PostForm form) =
    form.trip


pass (PostForm form) =
    form.pass


subj (PostForm form) =
    form.subj


text (PostForm form) =
    form.text


files (PostForm form) =
    Attachments.toList form.attachments


notUploadedFiles (PostForm form) =
    Attachments.toList form.attachments
        |> List.filter (\rec -> rec.backendID == Nothing)


disable (PostForm form) =
    PostForm { form | isEnabled = False }


enable (PostForm form) =
    PostForm { form | isEnabled = True }


autofocus (PostForm form) =
    PostForm { form | isAutofocus = True }


setName limits newName (PostForm form) =
    PostForm { form | name = limitString limits.maxLenName <| String.trimLeft newName }


setTrip newTrip (PostForm form) =
    PostForm { form | trip = String.trim newTrip }


setPass newPass (PostForm form) =
    PostForm { form | pass = String.trim newPass }


setSubj limits newSubj (PostForm form) =
    PostForm { form | subj = Just (limitString limits.maxLenSubj <| String.trimLeft newSubj) }


setText limits newText (PostForm form) =
    PostForm { form | text = limitString limits.maxLenText newText }


addFiles filesToAdd (PostForm form) =
    let
        ( newAttachments, cmdGeneratePreviews ) =
            Attachments.add AttachmentPreviewGenerated filesToAdd form.attachments
    in
    ( PostForm { form | attachments = newAttachments }, cmdGeneratePreviews )


setFilePreview fileID preview (PostForm form) =
    PostForm { form | attachments = Attachments.map fileID (Attachment.updatePreview preview) form.attachments }


setFileBackendID fileID backendID (PostForm form) =
    PostForm { form | attachments = Attachments.map fileID (Attachment.updateBackendID backendID) form.attachments }


removeFile fileID (PostForm form) =
    PostForm { form | attachments = Attachments.remove fileID form.attachments }


limitString maybeLimit str =
    maybeLimit
        |> Maybe.map (\maxLen -> String.left maxLen str)
        >> Maybe.withDefault str


countChars (PostForm form) =
    String.length <| form.text


countWords (PostForm form) =
    let
        words =
            String.words (String.trim form.text)
                |> List.filter isWord
    in
    List.length words


isWord str =
    not (String.isEmpty str)



-- Update


update : List String -> Limits -> Msg -> PostForm -> ResultUpdate
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

        AttachmentPreviewGenerated fileID preview ->
            Ok (setFilePreview fileID preview postForm) Cmd.none

        RemoveFile fileID ->
            Ok (removeFile fileID postForm) Cmd.none

        Unfocus id ->
            Ok postForm (Dom.blur id |> Task.attempt (\_ -> NoOp))

        Submit ->
            let
                filesUploadCmds =
                    notUploadedFiles postForm
                        |> List.map (Attachment.upload FileUploaded)

                cmd =
                    if List.isEmpty filesUploadCmds then
                        submit submitPath postForm

                    else
                        Cmd.batch filesUploadCmds
            in
            Ok (disable postForm) cmd

        FormSubmitted result ->
            case result of
                Result.Err httpError ->
                    Err (Alert.fromHttpError httpError) (enable postForm)

                Result.Ok () ->
                    Submitted postForm

        FileUploaded result ->
            case result of
                Result.Err httpError ->
                    Err (Alert.fromHttpError httpError) (enable postForm)

                Result.Ok ( fileID, backendID ) ->
                    let
                        newPostForm =
                            setFileBackendID fileID backendID postForm

                        cmd =
                            if List.isEmpty (notUploadedFiles newPostForm) then
                                submit submitPath newPostForm

                            else
                                Cmd.none
                    in
                    Ok newPostForm cmd



-- View


view theme limits form =
    let
        style =
            classes [ TC.h_100, TC.w_100, TC.flex, TC.flex_row ]
    in
    div [ style ]
        [ viewMeta theme limits form
        , viewPostBody theme form
        ]


viewMeta theme limits form =
    let
        style =
            classes [ TC.pl2, TC.pr3, TC.mw5, TC.flex, TC.flex_column ]
    in
    div [ style ] <|
        viewNameInput theme form
            ++ viewTripInput theme form
            ++ viewPassInput theme form
            ++ [ buttonCreate theme form
               , viewProblems theme form
               , div [ class TC.flex_grow_1 ] []
               ]
            ++ viewInfo limits form


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


viewPostBody theme form =
    let
        style =
            classes [ TC.pl3, TC.flex_grow_1, TC.flex, TC.flex_column ]
    in
    div [ style ] <|
        viewPostSubj theme form
            ++ viewPostComment theme form
            ++ viewAttachments theme form


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


viewAttachments theme form =
    [ formLabel "Attached Images"
    , div [ classes [ TC.flex, TC.justify_center ], styleFormElement ] <|
        List.map (viewAttachment theme) (files form)
            ++ [ viewButtonSelectAttachments theme form ]
    ]


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
                [ TC.absolute
                , TC.h_100
                , TC.w_100
                , TC.pl3
                , TC.pr3
                , TC.flex
                , TC.justify_center
                , TC.flex_column
                , TC.tc
                , TC.child
                , TC.bg_black_70
                ]
    in
    Maybe.map previewImg preview
        |> Maybe.withDefault (viewPreviewLoadingSpinner theme)


viewPreviewLoadingSpinner theme =
    div [ styleFormMediaPreview ] [ Spinner.view theme 64 ]


viewButtonSelectAttachments theme form =
    let
        style =
            classes [ TC.b__dashed, TC.pa3, TC.tc, TC.br1, TC.bw1, TC.bg_transparent, theme.fgPost, theme.bInput ]
    in
    div
        [ style
        , Style.flexFiller
        , Style.button theme (isEnabled form)
        , onClick SelectFiles
        ]
        [ div [ Tachyons.classes [ TC.h_100, TC.flex, TC.flex_column, TC.justify_center ] ]
            [ div [] [ Html.text "Add Images" ] ]
        ]


viewPostComment theme form =
    let
        style =
            classes [ TC.flex_grow_1, TC.pa1, TC.br1, TC.b__solid, TC.bw1, TC.w_100, theme.fgInput, theme.bgInput, theme.bInput ]
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


buttonCreate theme form =
    let
        disabledAttrs =
            if isValid form && isEnabled form then
                [ disabled False, Style.buttonEnabled theme ]

            else
                [ disabled True, Style.buttonDisabled theme ]
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


viewProblems theme form =
    let
        textCantBeBlank =
            formProblem theme "Post should have a comment or an attachment."
                |> viewIf
                    (isTextBlank form
                        && not (hasAttachments form)
                    )
    in
    div [ class TC.h3 ] [ textCantBeBlank ]


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


formLabel str =
    label [ styleFormElement ] [ Html.text str ]


formProblem theme str =
    div [ styleFormElement, classes [ theme.fgAlert ] ] [ Html.text str ]


formInfo strLabel strVal =
    div [ styleFormElement ] [ Html.text <| strLabel ++ ": ", Html.text strVal ]


unfocusOnEsc id =
    Keyboard.Events.on Keyboard.Events.Keydown [ ( Keyboard.Escape, Unfocus id ) ]


styleTextInput theme =
    classes [ TC.pa1, TC.br1, TC.b__solid, theme.fgInput, theme.bgInput, theme.bInput ]


styleFormElement =
    classes [ TC.db, TC.mb3, TC.w_100 ]


styleFormMediaPreview =
    classes [ TC.h4, TC.w4, TC.mr2, TC.relative, TC.hide_child, TC.pointer, TC.overflow_hidden, TC.br1, TC.cover, TC.bg_center ]


styleFromButton =
    classes [ TC.mt3, TC.mb4 ]
