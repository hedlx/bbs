module Model.Page exposing
    ( Page(..)
    , State(..)
    , mapContent
    , mapIndex
    , mapLoading
    , mapThread
    , withLoadingDefault
    )

import Model.Thread
import Model.ThreadForm as ThreadForm exposing (ThreadForm)


type Page
    = NotFound
    | Index (State () (List Model.Thread.Thread))
    | Thread (State Int Model.Thread.Thread)
    | NewThread ThreadForm


type State a b
    = Loading a
    | Content b


mapContent f state =
    case state of
        Content data ->
            Content (f data)

        Loading loadData ->
            Loading loadData


mapLoading f state =
    case state of
        Loading data ->
            Loading (f data)

        Content data ->
            Content data


withLoadingDefault placeholder state =
    case state of
        Loading _ ->
            placeholder

        Content data ->
            data


mapIndex f page =
    case page of
        Index maybeThreads ->
            Index (f maybeThreads)

        _ ->
            page


mapThread f page =
    case page of
        Thread state ->
            Thread (f state)

        _ ->
            page


isLoading page =
    case page of
        Index (Loading _) ->
            True

        Thread (Loading _) ->
            True

        _ ->
            False
