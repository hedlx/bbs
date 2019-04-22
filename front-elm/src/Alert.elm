module Alert exposing (Alert(..), Msg, State, add, fromHttpError, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Style.Animations as Animations
import Tachyons exposing (classes)
import Tachyons.Classes as TC
import Theme exposing (Theme)
import Toasty



-- Data


type Alert
    = Warning String
    | Error String


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
        ( newState, cmd ) =
            Toasty.addPersistentToast Toasty.config (toMsg << ToastyMsg) alert ( state, Cmd.none )
    in
    ( Alerts newState, cmd )



-- Model


type State
    = Alerts { toasties : Toasty.Stack Alert }


type Msg
    = ToastyMsg (Toasty.Msg Alert)


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
    Toasty.view (configView theme) (viewAlert theme) ToastyMsg state.toasties


configView : Theme -> Toasty.Config msg
configView theme =
    Toasty.config
        |> Toasty.containerAttrs [ stylePopUpStack theme ]


viewAlert : Theme -> Alert -> Html msg
viewAlert theme alert =
    case alert of
        Warning description ->
            div [ stylePopUp, stylePopUpWarn theme ]
                [ p [] [ h3 [] [ text "Warning" ] ]
                , p [] [ text description ]
                ]

        Error description ->
            div [ stylePopUp, stylePopUpErr theme ]
                [ p [] [ h3 [] [ text "Error" ] ]
                , p [] [ text description ]
                ]


stylePopUpStack : Theme -> Attribute msg
stylePopUpStack theme =
    classes
        [ TC.fixed
        , TC.w_30
        , TC.right_0
        , TC.ma0
        , TC.pa3
        , TC.z_max
        , TC.br3
        , TC.fr
        , TC.list
        , theme.font
        ]


stylePopUp : Attribute msg
stylePopUp =
    classes
        [ TC.pl3
        , TC.pr3
        , TC.pt1
        , TC.pb1
        , TC.ma2
        , TC.br1
        , TC.dim
        , TC.pointer
        , Animations.fadein_r
        ]


stylePopUpWarn : Theme -> Attribute msg
stylePopUpWarn theme =
    classes [ theme.fgPopUpWarn, theme.bgPopUpWarn ]


stylePopUpErr : Theme -> Attribute msg
stylePopUpErr theme =
    classes [ theme.fgPopUpErr, theme.bgPopUpErr ]
