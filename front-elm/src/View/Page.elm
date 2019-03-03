module View.Page exposing (view)

import Html exposing (..)
import Spinner
import View.Menu as Menu
import View.Threads as Threads


view style model =
    if model.isLoading then
        div [ style.page ]
            [ loadingSpinner model.spinner ]

    else
        div [ style.page ]
            [ Menu.view style model
            , Threads.view style model.threads
            ]


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
