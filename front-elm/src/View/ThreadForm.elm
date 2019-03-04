module View.ThreadForm exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
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
            ++ [ button
                    [ onClick Msg.FormSubmit
                    , style.textButton
                    , style.formButton
                    , style.formMetaElement
                    , disabled << not <| Model.ThreadForm.isValid form
                    ]
                    [ text "Create" ]
               ]


nameInput style form =
    [ label [ style.formMetaElement ] [ text "Name" ]
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
    [ label [ style.formMetaElement ] [ text "Password" ]
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
        [ label [ style.formMetaElement ] [ text "Post Body" ]
        , textarea
            [ value <| Model.ThreadForm.text form
            , style.textArea
            , style.flexFiller
            , onInput Msg.FormTextChanged
            , Html.Attributes.style "resize" "none"
            ]
            []
        ]
