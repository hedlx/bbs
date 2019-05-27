module Page.Response exposing (Response(..), map)

import Alert exposing (Alert)


type Response a msg
    = Ok a (Cmd msg)
    | Failed (Alert msg) a (Cmd msg)
    | Err (Alert msg)
    | Redirect (List String)
    | ReplyTo Int Int


map : (a -> b) -> (msgA -> msgB) -> Response a msgA -> Response b msgB
map fnA fnMsg response =
    case response of
        Ok a cmd ->
            Ok (fnA a) (Cmd.map fnMsg cmd)

        Failed alert a cmd ->
            Failed (Alert.map fnMsg alert) (fnA a) (Cmd.map fnMsg cmd)

        Err alert ->
            Err (Alert.map fnMsg alert)

        Redirect path ->
            Redirect path

        ReplyTo tID postNo ->
            ReplyTo tID postNo
