module Alert exposing (Alert(..), Description, Title, fromHttpError, map)

import Http


type Alert msg
    = None
    | Warning Title Description
    | Error Title Description
    | Confirm Title Description msg
    | Batch (List (Alert msg))


type alias Title =
    String


type alias Description =
    String


map : (msgA -> msgB) -> Alert msgA -> Alert msgB
map f alert =
    case alert of
        None ->
            None

        Warning title desc ->
            Warning title desc

        Error title desc ->
            Error title desc

        Confirm title desc msg ->
            Confirm title desc (f msg)

        Batch alerts ->
            Batch (List.map (map f) alerts)


fromHttpError : Http.Error -> Alert msg
fromHttpError error =
    let
        pleaseCheckConnection =
            "Please check your Internet connection and try again."

        pleaseReport =
            "\n Please, report this issue to developers."
    in
    case error of
        Http.Timeout ->
            Error "Server took to long to respond"
                pleaseCheckConnection

        Http.NetworkError ->
            Error "Network error "
                pleaseCheckConnection

        Http.BadUrl str ->
            Error "Bad request URL"
                (str ++ pleaseReport)

        Http.BadStatus statusCode ->
            Error "Server error"
                (String.fromInt statusCode ++ pleaseReport)

        Http.BadBody str ->
            Error "Bad request body"
                (str ++ pleaseReport)
