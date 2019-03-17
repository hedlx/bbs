module View.PopUp exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Model.PopUp
import Msg
import Toasty


view style model =
    Toasty.view (config style) (viewToast style) Msg.ToastyMsg model.plugins.toasties


viewToast style toast =
    case toast of
        Model.PopUp.Warning description ->
            div [ style.popUp, style.popUpWarn ]
                [ p [] [ h3 [] [ text "Warning" ] ]
                , p [] [ text description ]
                ]

        Model.PopUp.Error description ->
            div [ style.popUp, style.popUpErr ]
                [ p [] [ h3 [] [ text "Error" ] ]
                , p [] [ text description ]
                ]


config style =
    Toasty.config
        |> Toasty.containerAttrs [ style.popUpStack ]
