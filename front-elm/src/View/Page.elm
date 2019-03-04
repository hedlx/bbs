module View.Page exposing (view)

import Html exposing (..)
import Model.Page
import Spinner
import View.Menu as Menu
import View.ThreadForm as ThreadForm
import View.Threads as Threads


view style model =
    div [ style.page ]
        [ Menu.view style model
        , content style model
        ]


content style model =
    let
        pageView =
            case model.page of
                Model.Page.Index ->
                    Threads.view style model.threads

                Model.Page.NewThread form ->
                    ThreadForm.view style form

                Model.Page.NotFound ->
                    h1 [] [ text "Page Not Found" ]
    in
    if model.isLoading then
        loadingSpinner model.spinner

    else
        pageView


loadingSpinner spinner =
    Spinner.view loadingSpinnerCfg spinner


loadingSpinnerCfg =
    let
        defaultCfg =
            Spinner.defaultConfig
    in
    { defaultCfg
        | direction = Spinner.Counterclockwise
    }
