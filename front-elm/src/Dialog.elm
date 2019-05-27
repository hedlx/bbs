module Dialog exposing (Dialog, cancel, closed, confirm, view, visible)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (nothing)
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)


visible : String -> String -> msg -> Dialog msg
visible title desc msgOk =
    Visible (State title desc msgOk)


confirm : Dialog msg -> ( Dialog msg, Maybe msg )
confirm dialog =
    case dialog of
        Closed ->
            ( Closed, Nothing )

        Visible state ->
            ( Closed, Just state.msgOnOk )


cancel : Dialog msg -> Dialog msg
cancel _ =
    closed


closed : Dialog msg
closed =
    Closed


type Dialog msg
    = Closed
    | Visible (State msg)


type alias State msg =
    { title : String
    , description : String
    , msgOnOk : msg
    }


type alias EventHandlers msg =
    { onOk : msg
    , onCancel : msg
    }


view : Theme -> EventHandlers msg -> Dialog msg -> Html msg
view theme evHandlers dialog =
    case dialog of
        Closed ->
            nothing

        Visible state ->
            viewOverlay
                [ viewDialog theme evHandlers state ]


viewOverlay : List (Html msg) -> Html msg
viewOverlay =
    aside
        [ classes
            [ T.fixed
            , T.z_max
            , T.vh_100
            , T.w_100
            , T.bg_black_60
            , T.flex
            , T.flex_column
            , T.content_center
            , T.justify_center
            , T.items_center
            ]
        ]


viewDialog : Theme -> EventHandlers msg -> State msg -> Html msg
viewDialog theme evHandlers state =
    let
        style =
            classes
                [ T.w_90
                , T.w_auto_ns
                , theme.bgDialog
                , theme.fgDialog
                , T.flex
                , T.flex_column
                , T.br3
                , T.pa3
                ]

        styleBtn =
            classes
                [ T.fr
                , T.ml3
                , T.pa2
                , T.pa1_ns
                , T.br2
                ]
    in
    div [ style ]
        [ h3 [ classes [ T.pa0, T.ma0 ] ] [ text state.title ]
        , p [ classes [ T.w5, T.h3_ns ] ] [ text state.description ]
        , div [ class T.flex_grow_1 ] []
        , div []
            [ button [ styleBtn, onClick evHandlers.onOk ] [ text "Ok" ]
            , button [ styleBtn, onClick evHandlers.onCancel ] [ text "Cancel" ]
            ]
        ]
