module SlideIn exposing (Msg, SlideIn, Toast(..), add, init, update, view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Style.Animations as Animations
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Toasty


init : SlideIn
init =
    SlideIn { toasties = Toasty.initialState }



-- Model


type SlideIn
    = SlideIn { toasties : Toasty.Stack Toast }


type Toast
    = Warning Title Description
    | Error Title Description


type alias Title =
    String


type alias Description =
    String


add : Toast -> SlideIn -> ( SlideIn, Cmd Msg )
add toast (SlideIn state) =
    let
        ( newState, cmd ) =
            Toasty.addPersistentToast Toasty.config ToastyMsg toast ( state, Cmd.none )
    in
    ( SlideIn newState, cmd )


type Msg
    = ToastyMsg (Toasty.Msg Toast)


update : Msg -> SlideIn -> ( SlideIn, Cmd Msg )
update msg (SlideIn state) =
    case msg of
        ToastyMsg msgToasty ->
            let
                ( newState, cmds ) =
                    Toasty.update Toasty.config ToastyMsg msgToasty state
            in
            ( SlideIn newState, cmds )



-- View


view : Theme -> SlideIn -> Html Msg
view theme (SlideIn state) =
    Toasty.view (configView theme) (viewToast theme) ToastyMsg state.toasties


configView : Theme -> Toasty.Config msg
configView theme =
    Toasty.config
        |> Toasty.containerAttrs [ styleSlideInStack theme ]


viewToast : Theme -> Toast -> Html msg
viewToast theme toast =
    case toast of
        Warning title desc ->
            viewToastAlert (styleSlideInWarn theme) title desc

        Error title desc ->
            viewToastAlert (styleSlideInErr theme) title desc


viewToastAlert : Attribute msg -> Title -> Description -> Html msg
viewToastAlert attrStyle title desc =
    div [ styleSlideIn, attrStyle ]
        [ h3 [] [ text title ]
        , p [ style "word-break" "break-word" ] [ text desc ]
        ]


styleSlideInStack : Theme -> Attribute msg
styleSlideInStack theme =
    classes
        [ T.fixed
        , T.w_auto_ns
        , T.mw9_ns
        , T.right_0
        , T.ma0
        , T.pa3
        , T.z_max
        , T.br3
        , T.fr
        , T.list
        , theme.font
        ]


styleSlideIn : Attribute msg
styleSlideIn =
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


styleSlideInWarn : Theme -> Attribute msg
styleSlideInWarn theme =
    classes [ theme.fgSlideInWarn, theme.bgSlideInWarn ]


styleSlideInErr : Theme -> Attribute msg
styleSlideInErr theme =
    classes [ theme.fgSlideInErr, theme.bgSlideInErr ]
