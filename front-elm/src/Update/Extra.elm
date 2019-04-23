module Update.Extra exposing
    ( andThen
    , andThenIf
    , compose
    , map
    , return
    )


return : a -> ( a, Cmd msg )
return a =
    ( a, Cmd.none )


map : (a -> b) -> ( a, Cmd msg ) -> ( b, Cmd msg )
map =
    Tuple.mapFirst


compose : (a -> ( b, Cmd msg )) -> (b -> ( c, Cmd msg )) -> a -> ( c, Cmd msg )
compose f g =
    andThen g << f


andThen : (a -> ( b, Cmd msg )) -> ( a, Cmd msg ) -> ( b, Cmd msg )
andThen updateA ( a, cmdA ) =
    case updateA a of
        ( b, cmdB ) ->
            ( b, Cmd.batch [ cmdA, cmdB ] )


andThenIf : (a -> Bool) -> (a -> ( a, Cmd msg )) -> ( a, Cmd msg ) -> ( a, Cmd msg )
andThenIf pred updateA ( a, cmdA ) =
    if pred a then
        andThen updateA ( a, cmdA )

    else
        ( a, cmdA )
