module View.Page exposing (view)

import Html exposing (..)
import Model.Page
import View.Menu as Menu
import View.NewThread as NewThread
import View.NotFound as NotFound
import View.Spinner as Spinner
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
            Model.Page.mapContent (Threads.view style) state
                |> loadingSpinner style

        Model.Page.Thread state ->
            Model.Page.mapContent (Thread.view style) state
                |> loadingSpinner style

        Model.Page.NewThread form ->
            NewThread.view style form

        Model.Page.NotFound ->
            NotFound.view style


loadingSpinner style =
    Model.Page.withLoadingDefault (Spinner.view style 256)
