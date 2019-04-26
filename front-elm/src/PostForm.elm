module PostForm exposing
    ( Msg
    , PostForm
    , Response(..)
    , appendToText
    , autofocus
    , disable
    , empty
    , enable
    , enableSubj
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
import Config exposing (Config)
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
    , name : Maybe String
    , trip : Maybe String
    , pass : Maybe String
    , subj : Optional String
    , text : String
    , attachments : Attachments
    }


type Optional a
    = Hidden
    | Visible a


optToMaybe : Optional a -> Maybe a
optToMaybe opt =
    case opt of
        Hidden ->
            Nothing

        Visible a ->
            Just a


mapOpt : (a -> b) -> Optional a -> Optional b
mapOpt f opt =
    case opt of
        Hidden ->
            Hidden

        Visible a ->
            Visible (f a)


empty : PostForm
empty =
    PostForm emptyRaw


emptyRaw : PostForm_
emptyRaw =
    { isEnabled = True
    , isAutofocus = False
    , name = Nothing
    , trip = Nothing
    , pass = Nothing
    , subj = Hidden
    , text = ""
    , attachments = Attachments.empty
    }


clean : PostForm -> PostForm
clean (PostForm form) =
    PostForm
        { emptyRaw
            | name = Just ""
            , trip = Just ""
            , pass = Just ""
            , subj = mapOpt (\_ -> "") form.subj
        }


reset : PostForm -> PostForm
reset (PostForm form) =
    PostForm
        { emptyRaw
            | name = Nothing
            , trip = Nothing
            , pass = Nothing
            , subj = mapOpt (\_ -> "") form.subj
        }


isUserDataEmpty : PostForm -> Bool
isUserDataEmpty (PostForm form) =
    form.name
        == Nothing
        && form.trip
        == Nothing
        && form.pass
        == Nothing


isBlank : PostForm -> Bool
isBlank (PostForm form) =
    String.isEmpty form.text
        && isMaybeStrEmpty (optToMaybe form.subj)
        && isMaybeStrEmpty form.name
        && isMaybeStrEmpty form.trip
        && isMaybeStrEmpty form.pass
        && Attachments.isEmpty form.attachments


isMaybeStrEmpty : Maybe String -> Bool
isMaybeStrEmpty maybeStr =
    case maybeStr of
        Nothing ->
            True

        Just "" ->
            True

        _ ->
            False


isTextBlank : PostForm -> Bool
isTextBlank (PostForm form) =
    String.isEmpty (String.trim form.text)


isValid : PostForm -> Bool
isValid postForm =
    not (isTextBlank postForm)
        || not (Attachments.isEmpty (attachments postForm))


isEnabled : PostForm -> Bool
isEnabled (PostForm form) =
    form.isEnabled


isAutofocus : PostForm -> Bool
isAutofocus (PostForm form) =
    form.isAutofocus


hasAttachments : PostForm -> Bool
hasAttachments (PostForm form) =
    not (Attachments.isEmpty form.attachments)


name : Config -> PostForm -> String
name cfg (PostForm form) =
    Maybe.withDefault cfg.name form.name


trip : Config -> PostForm -> String
trip cfg (PostForm form) =
    Maybe.withDefault cfg.trip form.trip


pass : Config -> PostForm -> String
pass cfg (PostForm form) =
    Maybe.withDefault cfg.pass form.pass


subj : PostForm -> Maybe String
subj (PostForm form) =
    optToMaybe form.subj


text : PostForm -> String
text (PostForm form) =
    form.text


attachments : PostForm -> Attachments
attachments (PostForm form) =
    form.attachments


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


enableSubj : PostForm -> PostForm
enableSubj (PostForm form) =
    case form.subj of
        Hidden ->
            PostForm { form | subj = Visible "" }

        Visible _ ->
            PostForm form


autofocus : PostForm -> PostForm
autofocus (PostForm form) =
    PostForm { form | isAutofocus = True }


setName : Limits -> String -> PostForm -> PostForm
setName limits newName (PostForm form) =
    PostForm { form | name = Just << limitString limits.maxLenName <| String.trimLeft newName }


setTrip : String -> PostForm -> PostForm
setTrip newTrip (PostForm form) =
    PostForm { form | trip = Just (String.trim newTrip) }


setPass : String -> PostForm -> PostForm
setPass newPass (PostForm form) =
    PostForm { form | pass = Just (String.trim newPass) }


setSubj : Limits -> String -> PostForm -> PostForm
setSubj limits newSubj (PostForm form) =
    let
        newSubjTrimmed =
            limitString limits.maxLenSubj (String.trimLeft newSubj)
    in
    PostForm { form | subj = mapOpt (\_ -> newSubjTrimmed) form.subj }


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


submit : List String -> Config -> PostForm -> Cmd Msg
submit submitPath cfg postForm =
    Http.post
        { url = Url.Builder.crossOrigin Env.urlAPI submitPath []
        , body = Http.jsonBody (encode cfg postForm)
        , expect = Http.expectWhatever FormSubmitted
        }


encode : Config -> PostForm -> Encode.Value
encode cfg postForm =
    let
        nameForm =
            name cfg postForm

        fixedName =
            if String.isEmpty nameForm then
                Env.defaultName

            else
                nameForm

        formSubjOrEmpty =
            subj postForm
                |> Maybe.map (\subjVal -> [ ( "subject", Encode.string subjVal ) ])
                >> Maybe.withDefault []
    in
    Encode.object <|
        [ ( "name", Encode.string fixedName )
        , ( "secret", Encode.string (trip cfg postForm) )
        , ( "password", Encode.string (pass cfg postForm) )
        , ( "text", Encode.string (text postForm) )
        , ( "media", Attachments.encode (attachments postForm) )
        ]
            ++ formSubjOrEmpty



-- Update


type Msg
    = NoOp
    | Clean
    | Reset
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


update : List String -> Config -> Msg -> PostForm -> Response
update submitPath cfg msg postForm =
    case msg of
        NoOp ->
            Ok postForm Cmd.none

        Clean ->
            Ok (clean postForm) Cmd.none

        Reset ->
            Ok (reset postForm) Cmd.none

        NameChanged newVal ->
            Ok (setName cfg.limits newVal postForm) Cmd.none

        TripChanged newVal ->
            Ok (setTrip newVal postForm) Cmd.none

        PassChanged newVal ->
            Ok (setPass newVal postForm) Cmd.none

        SubjChanged newVal ->
            Ok (setSubj cfg.limits newVal postForm) Cmd.none

        TextChanged newVal ->
            Ok (setText cfg.limits newVal postForm) Cmd.none

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
                        submit submitPath cfg postForm

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
                                submit submitPath cfg newPostForm

                            else
                                Cmd.none
                    in
                    Ok newPostForm cmd



-- View


view : Config -> PostForm -> Html Msg
view cfg form =
    let
        style =
            classes [ T.h_100, T.w_100, T.flex, T.flex_row ]
    in
    Html.form [ style ]
        [ viewMeta cfg form
        , viewPostBody cfg.theme form
        ]


viewMeta : Config -> PostForm -> Html Msg
viewMeta cfg form =
    let
        theme =
            cfg.theme

        limits =
            cfg.limits

        style =
            classes [ T.pl2, T.pr3, T.mw5, T.flex, T.flex_column ]
    in
    div [ style ] <|
        viewNameInput cfg form
            ++ viewTripInput cfg form
            ++ viewPassInput cfg form
            ++ [ viewBtnCleanOrReset cfg form
               , viewBtnSubmit theme form
               , viewProblems theme form
               , div [ class T.flex_grow_1 ] []
               ]
            ++ viewInfo limits form


viewNameInput : Config -> PostForm -> List (Html Msg)
viewNameInput cfg form =
    [ formLabel "Name"
    , input
        [ id "post-form-input"
        , unfocusOnEsc "post-form-input"
        , type_ "text"
        , value (name cfg form)
        , styleTextInput cfg.theme
        , styleFormElement
        , onInput NameChanged
        , placeholder Env.defaultName
        , disabled << not <| isEnabled form
        ]
        []
    ]


viewTripInput : Config -> PostForm -> List (Html Msg)
viewTripInput cfg form =
    [ formLabel "Tripcode Secret"
    , input
        [ id "post-form-trip"
        , unfocusOnEsc "post-form-trip"
        , type_ "text"
        , value (trip cfg form)
        , styleTextInput cfg.theme
        , styleFormElement
        , onInput TripChanged
        , disabled << not <| isEnabled form
        ]
        []
    ]


viewPassInput : Config -> PostForm -> List (Html Msg)
viewPassInput cfg form =
    [ formLabel "Password"
    , input
        [ id "post-form-pass"
        , unfocusOnEsc "post-form-pass"
        , type_ "password"
        , value (pass cfg form)
        , styleTextInput cfg.theme
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
        List.map (viewAttachment theme) (Attachments.toList (attachments form))
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
            classes
                [ T.b__dashed
                , T.pa3
                , T.tc
                , T.br1
                , T.bw1
                , T.dim
                , T.pointer
                , T.bg_transparent
                , theme.fgPost
                , theme.bInput
                ]
    in
    div
        [ style
        , Style.flexFill
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


viewBtnCleanOrReset : Config -> PostForm -> Html Msg
viewBtnCleanOrReset cfg form =
    let
        theme =
            cfg.theme

        isMetaExists =
            not (String.isEmpty cfg.name && String.isEmpty cfg.trip && String.isEmpty cfg.pass)

        isResetVisible =
            isMetaExists && (not (isUserDataEmpty form) || not (isBlank form))
    in
    if isResetVisible then
        button
            ([ onClick Reset
             , title "Reset all fields"
             ]
                ++ buttonAttrs theme True
            )
            [ Html.text "Reset" ]

    else
        button
            ([ onClick Clean
             , title "Clean all fields"
             ]
                ++ buttonAttrs theme (not (isBlank form) || isMetaExists)
            )
            [ Html.text "Clean" ]


viewBtnSubmit : Theme -> PostForm -> Html Msg
viewBtnSubmit theme form =
    let
        isBtnEnabled =
            isEnabled form && isValid form
    in
    button
        (onClick Submit :: buttonAttrs theme isBtnEnabled)
        [ Html.text "Post" ]


buttonAttrs : Theme -> Bool -> List (Attribute Msg)
buttonAttrs theme isBtnEnabled =
    let
        dynamicAttrs =
            if isBtnEnabled then
                [ disabled False
                , Style.buttonEnabled theme
                , classes [ theme.fgButton, theme.bgButton ]
                ]

            else
                [ disabled True
                , classes [ theme.fgButtonDisabled, theme.bgButtonDisabled ]
                ]
    in
    [ type_ "button"
    , Style.textButton theme
    , styleFromButton
    , styleFormElement
    ]
        ++ dynamicAttrs


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
    div [ classes [ T.h3, T.mt2 ] ] [ textCantBeBlank ]


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
    classes [ T.mt3 ]


unfocusOnEsc : String -> Attribute Msg
unfocusOnEsc elemID =
    Keyboard.Events.on Keyboard.Events.Keydown [ ( Keyboard.Escape, Unfocus elemID ) ]
