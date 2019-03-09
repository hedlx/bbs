module View.PostForm exposing (view)

import Env
import File
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Model.PostForm
import Msg
import Tachyons
import Tachyons.Classes as TC
import View.Icons as Icons


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
            ++ [ buttonCreate style form ]
            ++ [ problems style form ]
            ++ [ div [ style.flexFiller ] [] ]
            ++ info style form


nameInput style form =
    [ formLabel style "Name"
    , input
        [ type_ "text"
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
        [ type_ "text"
        , value <| Model.PostForm.trip form
        , style.textInput
        , style.formElement
        , onInput Msg.FormTripChanged
        ]
        []
    ]


passInput style form =
    [ formLabel style "Password"
    , input
        [ type_ "password"
        , value <| Model.PostForm.pass form
        , style.textInput
        , style.formElement
        , onInput Msg.FormPassChanged
        ]
        []
    ]


postBody style form =
    div [ style.formBodyPane ] <|
        postSubj style form
            ++ postTextInput style form
            ++ postFiles style form


postSubj style form =
    case Model.PostForm.subj form of
        Just subjVal ->
            [ formLabel style "Subject"
            , input
                [ type_ "text"
                , value subjVal
                , style.formElement
                , style.textInput
                , onInput Msg.FormSubjChanged
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


attachedFile style { id, file, preview } =
    div [ style.formImagePreviewContainer, onClick <| Msg.FormRemoveFile id ]
        [ img [ style.formImagePreview, src preview ] []
        , div
            [ style.formImagePreviewOverlay
            , Html.Attributes.style "top" "50%"
            , Html.Attributes.style "left" "50%"
            , Html.Attributes.style "transform" "translate(-50%, -50%)"
            ]
            [ div [] [ text "Remove" ] ]
        ]


buttonSelectFiles style form =
    div
        [ onClick Msg.FormSelectFiles
        , style.formButtonAddImage
        , style.flexFiller
        , style.buttonEnabled
        ]
        [ div [ Tachyons.classes [ TC.h_100, TC.flex, TC.flex_column, TC.justify_center ] ]
            [ div [] [ text "Add Images" ] ]
        ]


postTextInput style form =
    [ formLabel style "Comment"
    , textarea
        [ value <| Model.PostForm.text form
        , style.textArea
        , style.flexFiller
        , style.formElement
        , onInput Msg.FormTextChanged
        , Html.Attributes.style "resize" "none"
        ]
        []
    ]


buttonCreate style form =
    let
        disabledAttrs =
            if Model.PostForm.isValid form then
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
            viewIf (Model.PostForm.isTextBlank form) <|
                formProblem style "Comment can't be empty"
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
