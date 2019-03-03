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
        , pageContent style model
        ]


pageContent style model =
    if model.isLoading then
        loadingSpinner model.spinner

    else
        case model.page of
            Model.Page.Index ->
                Threads.view style model.threads

            Model.Page.NewThread ->
                ThreadForm.view style

            Model.Page.NotFound ->
                h1 [] [ text "Page Not Found" ]


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
