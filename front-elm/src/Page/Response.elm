module Page.Response exposing (Response(..), andThen, andThenIf, join, map, map2, return)

import Alert exposing (Alert)
import Page.Redirect exposing (Redirect)


type Response a msg
    = None
    | Ok a (Cmd msg) (Alert msg)
    | Err (Alert msg)
    | Redirect Redirect


return : a -> Response a msg
return state =
    Ok state Cmd.none Alert.None


map : (a -> b) -> Response a msg -> Response b msg
map f =
    map2 f identity


map2 : (a -> b) -> (msgA -> msgB) -> Response a msgA -> Response b msgB
map2 fnA fnMsg response =
    case response of
        None ->
            None

        Ok a cmd alert ->
            Ok (fnA a) (Cmd.map fnMsg cmd) (Alert.map fnMsg alert)

        Err alert ->
            Err (Alert.map fnMsg alert)

        Redirect path ->
            Redirect path


andThen : (a -> Response b msg) -> Response a msg -> Response b msg
andThen f response =
    join (map f response)


andThenIf : Bool -> (a -> Response a msg) -> Response a msg -> Response a msg
andThenIf isCond f response =
    if isCond then
        andThen f response

    else
        response


join : Response (Response a msg) msg -> Response a msg
join responseResponse =
    case responseResponse of
        None ->
            None

        Ok response cmdTop alertTop ->
            case response of
                Ok a cmd alert ->
                    Ok a (Cmd.batch [ cmd, cmdTop ]) (Alert.Batch [ alert, alertTop ])

                _ ->
                    response

        Err alertTop ->
            Err alertTop

        Redirect redirect ->
            Redirect redirect
