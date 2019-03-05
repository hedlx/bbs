module View.ThreadForm exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Model.ThreadForm
import Msg


view style form =
    div [ style.content ]
        [ div
            [ style.formContainer ]
            [ meta style form
            , postBody style form
            ]
        ]


meta style form =
    div [ style.formMetaPane ] <|
        nameInput style form
            ++ passInput style form
            ++ [ buttonCreate style form ]
            ++ problems style form
            ++ [ div [ style.flexFiller ] [] ]
            ++ info style form


nameInput style form =
    [ formLabel style "Name"
    , input
        [ type_ "text"
        , value <| Model.ThreadForm.name form
        , style.textInput
        , style.formMetaElement
        , onInput Msg.FormNameChanged
        , placeholder "Anonymous"
        ]
        []
    ]


passInput style form =
    [ formLabel style "Tripcode Secret"
    , input
        [ type_ "text"
        , value <| Model.ThreadForm.pass form
        , style.textInput
        , style.formMetaElement
        , onInput Msg.FormPassChanged
        ]
        []
    ]


postBody style form =
    div [ style.formBodyPane ]
        [ formLabel style "Comment"
        , textarea
            [ value <| Model.ThreadForm.text form
            , style.textArea
            , style.flexFiller
            , onInput Msg.FormTextChanged
            , Html.Attributes.style "resize" "none"
            ]
            []
        ]


buttonCreate style form =
    let
        disabledAttrs =
            if Model.ThreadForm.isValid form then
                [ disabled False, style.textButtonEnabled ]

            else
                [ disabled True, style.textButtonDisabled ]
    in
    button
        ([ onClick Msg.FormSubmit
         , style.textButton
         , style.formButton
         , style.formMetaElement
         ]
            ++ disabledAttrs
        )
        [ text "Create" ]


problems style form =
    let
        textCantBeBlank =
            viewIf (Model.ThreadForm.isTextBlank form) <|
                formProblem style "Comment can't be empty"
    in
    [ textCantBeBlank ]


info style form =
    let
        postBodyText =
            Model.ThreadForm.text form

        charsCount =
            String.fromInt << String.length <| postBodyText

        words =
            String.words (String.trim postBodyText)
                |> List.filter (not << String.isEmpty)

        wordsCount =
            String.fromInt (List.length words)
    in
    [ formInfo style "Symbols" (charsCount ++ " / Inf")
    , formInfo style "Words" (wordsCount ++ " / Inf")
    ]


formLabel style str =
    label [ style.formMetaElement ] [ text str ]


formProblem style str =
    div [ style.formMetaElement, style.alert ] [ text str ]


formInfo style strLabel strVal =
    div [ style.formMetaElement ] [ text <| strLabel ++ ": ", text strVal ]
