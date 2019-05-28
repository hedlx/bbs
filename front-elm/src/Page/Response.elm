module Page.Response exposing (Response(..), andThen, andThenIf, join, map, map2)

import Alert exposing (Alert)


type Response a msg
    = None
    | Ok a (Cmd msg)
    | Err (Alert msg)
    | Failed (Alert msg) a (Cmd msg)
    | Redirect (List String)
    | ReplyTo Int Int


map : (a -> b) -> Response a msg -> Response b msg
map f =
    map2 f identity


map2 : (a -> b) -> (msgA -> msgB) -> Response a msgA -> Response b msgB
map2 fnA fnMsg response =
    case response of
        None ->
            None

        Ok a cmd ->
            Ok (fnA a) (Cmd.map fnMsg cmd)

        Err alert ->
            Err (Alert.map fnMsg alert)

        Failed alert a cmd ->
            Failed (Alert.map fnMsg alert) (fnA a) (Cmd.map fnMsg cmd)

        Redirect path ->
            Redirect path

        ReplyTo tID postNo ->
            ReplyTo tID postNo


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

        Ok response cmdTop ->
            case response of
                Ok a cmd ->
                    Ok a (Cmd.batch [ cmd, cmdTop ])

                Failed alert a cmd ->
                    Failed alert a (Cmd.batch [ cmd, cmdTop ])

                other ->
                    other

        Err alertTop ->
            Err alertTop

        Failed alertTop response cmdTop ->
            case response of
                Ok a cmd ->
                    Failed alertTop a (Cmd.batch [ cmd, cmdTop ])

                Failed alert a cmd ->
                    Failed (Alert.Batch [ alert, alertTop ]) a (Cmd.batch [ cmd, cmdTop ])

                other ->
                    other

        Redirect path ->
            Redirect path

        ReplyTo tID postNo ->
            ReplyTo tID postNo
