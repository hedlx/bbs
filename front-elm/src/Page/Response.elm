module Page.Response exposing (Response(..), andThen, andThenIf, join, map, map2, raise, redirect, return)

import Alert exposing (Alert)
import Browser.Navigation as Nav
import Config exposing (Config)
import Route exposing (Route)


type Response a msg
    = None
    | Ok a (Cmd msg) (Alert msg)
    | Err (Cmd msg) (Alert msg)


raise : Alert msg -> Response a msg
raise alert =
    Err Cmd.none alert


redirect : Config -> Route -> Response a msg
redirect cfg route =
    Err (Nav.pushUrl cfg.key (Route.link route)) Alert.None


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

        Err cmd alert ->
            Err (Cmd.map fnMsg cmd) (Alert.map fnMsg alert)


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
                None ->
                    Err cmdTop alertTop

                Ok a cmd alert ->
                    Ok a (Cmd.batch [ cmd, cmdTop ]) (Alert.Batch [ alert, alertTop ])

                _ ->
                    response

        Err cmdTop alertTop ->
            Err cmdTop alertTop
