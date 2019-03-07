module View.Page exposing (view)

import Html exposing (..)
import Model.Page
import Spinner
import View.Menu as Menu
import View.NewThread as NewThread
import View.NotFound as NotFound
import View.Thread as Thread
import View.Threads as Threads


view style model =
    div [ style.page ]
        [ Menu.view style model
        , content style model
        ]


content style model =
    case model.page of
        Model.Page.Index state ->
            Model.Page.mapContent (Threads.view style model.cfg) state
                |> loadingSpinner model.spinner

        Model.Page.Thread state ->
            Model.Page.mapContent (Thread.view style model.cfg) state
                |> loadingSpinner model.spinner

        Model.Page.NewThread form ->
            NewThread.view style form

        Model.Page.NotFound ->
            NotFound.view style


loadingSpinner spinner =
    Spinner.view loadingSpinnerCfg spinner
        |> Model.Page.withLoadingDefault


loadingSpinnerCfg =
    let
        defaultCfg =
            Spinner.defaultConfig
    in
    { defaultCfg
        | lines = 11
        , length = 30
        , width = 30
        , radius = 90
        , scale = 0.5
        , corners = 1
        , opacity = 0.1
        , direction = Spinner.Counterclockwise
        , hwaccel = True
    }
