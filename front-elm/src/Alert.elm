module Alert exposing
    ( Alert(..)
    , Msg
    , State
    , add
    , fromHttpError
    , init
    , update
    , view
    )

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Style.Animations as Animations
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Toasty



-- Data


type Alert
    = None
    | Warning String
    | Error String
    | Batch (List Alert)


type Toast
    = ToastWarning String
    | ToastError String


fromHttpError : Http.Error -> Alert
fromHttpError error =
    let
        pleaseCheckConnection =
            "Please check your Internet connection and try again."

        pleaseReport =
            "\n Please, report this issue to developers."
    in
    case error of
        Http.Timeout ->
            Error <|
                "Server took to long to respond. "
                    ++ pleaseCheckConnection

        Http.NetworkError ->
            Error <|
                "Network error. "
                    ++ pleaseCheckConnection

        Http.BadUrl str ->
            Error <|
                "Something went wrong: Bad request URL.\n"
                    ++ str
                    ++ pleaseReport

        Http.BadStatus statusCode ->
            Error <|
                "Something went wrong: Server Error "
                    ++ String.fromInt statusCode
                    ++ pleaseReport

        Http.BadBody str ->
            Error <|
                "Something went wrong: Bad request body.\n"
                    ++ str
                    ++ pleaseReport


add : (Msg -> msg) -> Alert -> State -> ( State, Cmd msg )
add toMsg alert (Alerts state) =
    let
        toastAdders =
            List.map
                (Toasty.addPersistentToast Toasty.config (toMsg << ToastyMsg))
                (toToastList alert)

        addToasts =
            List.foldl (<<) identity toastAdders

        ( newState, cmd ) =
            addToasts ( state, Cmd.none )
    in
    ( Alerts newState, cmd )


toToastList : Alert -> List Toast
toToastList alert =
    case alert of
        None ->
            []

        Warning description ->
            [ ToastWarning description ]

        Error description ->
            [ ToastError description ]

        Batch alerts ->
            List.concatMap toToastList alerts



-- Model


type State
    = Alerts { toasties : Toasty.Stack Toast }


type Msg
    = ToastyMsg (Toasty.Msg Toast)


init : State
init =
    Alerts { toasties = Toasty.initialState }



-- Update


update : Msg -> State -> ( State, Cmd Msg )
update msg (Alerts state) =
    case msg of
        ToastyMsg msgToasty ->
            let
                ( newState, cmds ) =
                    Toasty.update Toasty.config ToastyMsg msgToasty state
            in
            ( Alerts newState, cmds )



-- View


view : Theme -> State -> Html Msg
view theme (Alerts state) =
    Toasty.view (configView theme) (viewToast theme) ToastyMsg state.toasties


configView : Theme -> Toasty.Config msg
configView theme =
    Toasty.config
        |> Toasty.containerAttrs [ stylePopUpStack theme ]


viewToast : Theme -> Toast -> Html msg
viewToast theme toast =
    case toast of
        ToastWarning description ->
            div [ stylePopUp, stylePopUpWarn theme ]
                [ p [] [ h3 [] [ text "Warning" ] ]
                , p [ style "word-break" "break-word" ] [ text description ]
                ]

        ToastError description ->
            div [ stylePopUp, stylePopUpErr theme ]
                [ p [] [ h3 [] [ text "Error" ] ]
                , p [ style "word-break" "break-word" ] [ text description ]
                ]


stylePopUpStack : Theme -> Attribute msg
stylePopUpStack theme =
    classes
        [ T.fixed
        , T.w_30_ns
        , T.right_0
        , T.ma0
        , T.pa3
        , T.z_max
        , T.br3
        , T.fr
        , T.list
        , theme.font
        ]


stylePopUp : Attribute msg
stylePopUp =
    classes
        [ T.pl3
        , T.pr3
        , T.pt1
        , T.pb1
        , T.ma2
        , T.br1
        , T.dim
        , T.pointer
        , Animations.fadein_right
        ]


stylePopUpWarn : Theme -> Attribute msg
stylePopUpWarn theme =
    classes [ theme.fgPopUpWarn, theme.bgPopUpWarn ]


stylePopUpErr : Theme -> Attribute msg
stylePopUpErr theme =
    classes [ theme.fgPopUpErr, theme.bgPopUpErr ]
