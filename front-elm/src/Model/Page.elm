module Model.Page exposing (Page(..), isLoadingRequired)


type Page
    = NotFound
    | Index
    | NewThread


isLoadingRequired page =
    case page of
        NotFound ->
            False

        Index ->
            True

        NewThread ->
            False
