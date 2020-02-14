module UserText exposing (Token(..), parseString)

import Parser as P
    exposing
        ( (|.)
        , (|=)
        , Parser
        , Step(..)
        , backtrackable
        , int
        , loop
        , map
        , oneOf
        , succeed
        , symbol
        , variable
        )
import Set
import String.Extra


type Token
    = Plain String
    | PostRefLocal Int
    | PostRef Int Int
    | ThreadRef Int


parseString : String -> List Token
parseString str =
    if String.Extra.isBlank str then
        []

    else
        Result.withDefault [ Plain str ] (P.run userText str)


userText : Parser (List Token)
userText =
    loop [] tokens


tokens : List Token -> Parser (P.Step (List Token) (List Token))
tokens tokensReversed =
    oneOf
        [ succeed (\token -> Loop (token :: tokensReversed))
            |= oneOf [ ref, plain ]
        , succeed ()
            |> map (\_ -> Done (List.reverse tokensReversed))
        ]


ref : Parser Token
ref =
    succeed identity
        |. symbol ">>"
        |= oneOf
            [ backtrackable postRef
            , backtrackable threadRef
            , backtrackable postRefLocal
            ]


postRefLocal : Parser Token
postRefLocal =
    succeed PostRefLocal
        |= int


threadRef : Parser Token
threadRef =
    succeed ThreadRef
        |= int
        |. symbol "/"


postRef : Parser Token
postRef =
    succeed PostRef
        |= int
        |. symbol "/"
        |= int


plain : Parser Token
plain =
    succeed Plain
        |= variable
            { start = always True
            , inner = (/=) '>'
            , reserved = Set.fromList []
            }
