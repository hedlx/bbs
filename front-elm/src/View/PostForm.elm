module View.PostForm exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Keyboard
import Keyboard.Events
import Model.PostForm
import Msg
import Tachyons
import Tachyons.Classes as TC
import View.Spinner as Spinner


view style form =
    div [ style.formContainer ]
        [ meta style form
        , postBody style form
        ]


meta style form =
    div [ style.formMetaPane ] <|
        nameInput style form
            ++ tripInput style form
            ++ passInput style form
            ++ [ buttonCreate style form
               , problems style form
               , div [ style.flexFiller ] []
               ]
            ++ info style form


nameInput style form =
    [ formLabel style "Name"
    , input
        [ id "post-form-input"
        , unfocusOnEsc "post-form-input"
        , type_ "text"
        , value <| Model.PostForm.name form
        , style.textInput
        , style.formElement
        , onInput Msg.FormNameChanged
        , placeholder "Anonymous"
        ]
        []
    ]


tripInput style form =
    [ formLabel style "Tripcode Secret"
    , input
        [ id "post-form-trip"
        , unfocusOnEsc "post-form-trip"
        , type_ "text"
        , value <| Model.PostForm.trip form
        , style.textInput
        , style.formElement
        , onInput Msg.FormTripChanged
        , disabled << not <| Model.PostForm.isEnabled form
        ]
        []
    ]


passInput style form =
    [ formLabel style "Password"
    , input
        [ id "post-form-pass"
        , unfocusOnEsc "post-form-pass"
        , type_ "password"
        , value <| Model.PostForm.pass form
        , style.textInput
        , style.formElement
        , onInput Msg.FormPassChanged
        , disabled << not <| Model.PostForm.isEnabled form
        ]
        []
    ]


postBody style form =
    div [ style.formBodyPane ] <|
        postSubj style form
            ++ postComment style form
            ++ postFiles style form


postSubj style form =
    case Model.PostForm.subj form of
        Just subjVal ->
            [ formLabel style "Subject"
            , input
                [ id "post-form-subj"
                , unfocusOnEsc "post-form-subj"
                , type_ "text"
                , value subjVal
                , style.formElement
                , style.textInput
                , onInput Msg.FormSubjChanged
                , disabled << not <| Model.PostForm.isEnabled form
                ]
                []
            ]

        Nothing ->
            []


postFiles style form =
    [ formLabel style "Attached Images"
    , areaAttachedFiles style form
    ]


areaAttachedFiles style form =
    div [ style.formAreaAttachedFiles, style.formElement ] <|
        attachedFiles style form
            ++ [ buttonSelectFiles style form ]


attachedFiles style form =
    List.map (attachedFile style) (Model.PostForm.files form)


attachedFile style { id, preview } =
    let
        previewImg base64Img =
            div
                [ style.formMediaPreview
                , Html.Attributes.style "background-image" <| String.concat [ "url('", base64Img, "')" ]
                , onClick <| Msg.FormRemoveFile id
                ]
                [ overlay ]

        overlay =
            div [ style.formMediaPreviewOverlay, Html.Attributes.style "visibility" "none" ] [ div [] [ text "Click to Remove" ] ]
    in
    preview
        |> Maybe.map previewImg
        >> Maybe.withDefault (previewLoadingSpinner style)


previewLoadingSpinner style =
    div [ style.formMediaPreview ] [ Spinner.view style 64 ]


buttonSelectFiles style form =
    let
        styleEnabledOrDisabled =
            if Model.PostForm.isEnabled form then
                style.buttonEnabled

            else
                style.buttonDisabled
    in
    div
        [ onClick Msg.FormSelectFiles
        , style.formButtonAddImage
        , style.flexFiller
        , styleEnabledOrDisabled
        ]
        [ div [ Tachyons.classes [ TC.h_100, TC.flex, TC.flex_column, TC.justify_center ] ]
            [ div [] [ text "Add Images" ] ]
        ]


postComment style form =
    [ formLabel style "Comment"
    , textarea
        [ id "post-form-text"
        , unfocusOnEsc "post-form-text"
        , value <| Model.PostForm.text form
        , style.textArea
        , style.flexFiller
        , style.formElement
        , onInput Msg.FormTextChanged
        , Html.Attributes.style "resize" "none"
        , disabled << not <| Model.PostForm.isEnabled form
        ]
        []
    ]


buttonCreate style form =
    let
        disabledAttrs =
            if Model.PostForm.isValid form && Model.PostForm.isEnabled form then
                [ disabled False, style.buttonEnabled ]

            else
                [ disabled True, style.buttonDisabled ]
    in
    button
        ([ onClick Msg.FormSubmit
         , style.textButton
         , style.formButton
         , style.formElement
         ]
            ++ disabledAttrs
        )
        [ text "Post" ]


problems style form =
    let
        textCantBeBlank =
            formProblem style "Post should have a comment or an attachment."
                |> viewIf
                    (Model.PostForm.isTextBlank form
                        && not (Model.PostForm.hasAttachments form)
                    )
    in
    div [ style.formProblems ] [ textCantBeBlank ]


info style form =
    let
        strMaxLenText =
            Model.PostForm.limits form
                |> .maxLenText
                >> Maybe.map String.fromInt
                >> Maybe.withDefault "..."
    in
    [ formInfo style
        "Symbols"
        (String.fromInt (Model.PostForm.countChars form)
            ++ " / "
            ++ strMaxLenText
        )
    , formInfo style "Words" (String.fromInt (Model.PostForm.countWords form))
    ]


formLabel style str =
    label [ style.formElement ] [ text str ]


formProblem style str =
    div [ style.formElement, style.alert ] [ text str ]


formInfo style strLabel strVal =
    div [ style.formElement ] [ text <| strLabel ++ ": ", text strVal ]


unfocusOnEsc id =
    Keyboard.Events.on Keyboard.Events.Keydown [ ( Keyboard.Escape, Msg.Unfocus id ) ]
