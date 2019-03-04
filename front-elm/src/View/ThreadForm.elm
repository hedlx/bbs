module View.ThreadForm exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Model.ThreadForm
import Msg


view style form =
    div []
        [ input
            [ type_ "text"
            , value <| Model.ThreadForm.name form
            , onInput Msg.FormNameChanged
            ]
            []
        , input
            [ type_ "text"
            , value <| Model.ThreadForm.pass form
            , onInput Msg.FormPassChanged
            ]
            []
        , textarea
            [ value <| Model.ThreadForm.text form
            , onInput Msg.FormTextChanged
            ]
            []
        , button
            [ onClick Msg.FormSubmit
            , disabled << not <| Model.ThreadForm.isValid form
            ]
            [ text "Create" ]
        ]
