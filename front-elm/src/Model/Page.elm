module Model.Page exposing (Page(..), index, isLoadingRequired, newThread, notFound)

import Model.ThreadForm as ThreadForm exposing (ThreadForm)


type Page
    = NotFound
    | Index
    | NewThread ThreadForm


isLoadingRequired page =
    case page of
        NotFound ->
            False

        Index ->
            True

        NewThread _ ->
            False


index =
    Index


newThread =
    NewThread ThreadForm.empty


notFound =
    NotFound
