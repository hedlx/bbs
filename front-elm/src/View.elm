module View exposing (view)

import Browser
import Html exposing (..)
import Model exposing (Model)
import Msg exposing (Msg)
import Tachyons
import Url
import View.Page as Page
import View.Style as Style


view : Model -> Browser.Document Msg
view model =
    let
        style =
            Style.fromTheme model.cfg.theme
    in
    { title = "Hedlx BBS"
    , body =
        [ Tachyons.tachyons.css
        , Page.view style model
        ]
    }
