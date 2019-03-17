module View exposing (view)

import Browser
import Env
import Html exposing (..)
import Model exposing (Model)
import Model.Page
import Msg exposing (Msg)
import String.Extra
import Tachyons
import View.Page as Page
import View.PopUp as PopUp
import View.Style as Style
import View.Style.Animations as Animations


view : Model -> Browser.Document Msg
view model =
    let
        style =
            Style.fromTheme model.cfg.theme

        pageTitle =
            Model.Page.title model.page

        title =
            if String.Extra.isBlank pageTitle then
                Env.bbsName

            else
                Env.bbsName ++ " | " ++ pageTitle
    in
    { title = title
    , body =
        [ Tachyons.tachyons.css
        , Animations.css
        , PopUp.view style model
        , Page.view style model
        ]
    }
