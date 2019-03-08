module View.PostForm exposing (view)

import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Model.PostForm
import Msg


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
        , style.formMetaElement
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
        , style.formMetaElement
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
        , style.formMetaElement
        , onInput Msg.FormPassChanged
        ]
        []
    ]


postBody style form =
    div [ style.formBodyPane ]
        [ formLabel style "Comment"
        , textarea
            [ value <| Model.PostForm.text form
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
            if Model.PostForm.isValid form then
                [ disabled False, style.textButton, style.buttonEnabled ]

            else
                [ disabled True, style.textButton, style.buttonDisabled ]
    in
    button
        ([ onClick Msg.FormSubmit
         , style.textButton
         , style.formButton
         , style.formMetaElement
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
    [ formInfo style
        "Symbols"
        (String.fromInt (Model.PostForm.countChars form)
            ++ " / "
            ++ String.fromInt Env.maxPostLength
        )
    , formInfo style "Words" (String.fromInt (Model.PostForm.countWords form))
    ]


formLabel style str =
    label [ style.formMetaElement ] [ text str ]


formProblem style str =
    div [ style.formMetaElement, style.alert ] [ text str ]


formInfo style strLabel strVal =
    div [ style.formMetaElement ] [ text <| strLabel ++ ": ", text strVal ]
