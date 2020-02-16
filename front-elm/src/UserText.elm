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
import Regex exposing (Regex)
import Set exposing (Set)
import String.Extra


type Token
    = Plain String
    | Quote String
    | Bold (List Token)
    | Italic (List Token)
    | Code String
    | CodeInline String
    | PostRefLocal Int
    | PostRef Int Int
    | ThreadRef Int


specialChars : Set Char
specialChars =
    Set.fromList [ '>', '*', '_', '`' ]


parseString : String -> List Token
parseString str =
    if String.Extra.isBlank str then
        []

    else
        Result.withDefault [ Plain str ] (P.run userText str)


userText : Parser (List Token)
userText =
    tokens
        { try =
            [ backtrackable ref
            , backtrackable quote
            , backtrackable
                (bold
                    [ map Plain (backtrackable oneAsterisk)
                    , backtrackable
                        (italic
                            [ plain
                            , plainSpecial [ '>', '*', '`' ]
                            ]
                        )
                    , plain
                    , plainSpecial [ '>', '_', '`' ]
                    ]
                )
            , backtrackable
                (italic
                    [ map Plain (backtrackable oneUnderscore)
                    , backtrackable
                        (bold
                            [ plain
                            , plainSpecial [ '>', '_', '`' ]
                            ]
                        )
                    , plain
                    , plainSpecial [ '>', '*', '`' ]
                    ]
                )
            , backtrackable code
            , backtrackable (plainSpecial [ '>', '*', '_', '`' ])
            , plain
            ]
        , stopAt = succeed ()
        }



-- Lexer


type alias TokensCfg a t =
    { try : List (Parser t)
    , stopAt : Parser a
    }


tokens : TokensCfg a t -> Parser (List t)
tokens cfg =
    loop [] (tokensStep cfg)


tokensStep : TokensCfg a t -> List t -> Parser (P.Step (List t) (List t))
tokensStep { stopAt, try } tokensReversed =
    oneOf
        [ succeed (\token -> Loop (token :: tokensReversed))
            |= oneOf try
        , stopAt
            |> map (\_ -> Done (List.reverse tokensReversed))
        ]



-- Plain Text


plain : Parser Token
plain =
    succeed Plain
        |= variable
            { start = \c -> not (Set.member c specialChars)
            , inner = \c -> not (Set.member c specialChars)
            , reserved = Set.fromList []
            }


plainSpecial : List Char -> Parser Token
plainSpecial allowedCharsList =
    succeed Plain
        |= strSpecial allowedCharsList


strSpecial : List Char -> Parser String
strSpecial allowedCharsList =
    let
        allowedChars =
            Set.fromList allowedCharsList
    in
    variable
        { start = \c -> Set.member c allowedChars
        , inner = always False
        , reserved = Set.empty
        }



-- Quotation


quote : Parser Token
quote =
    succeed Quote
        |. symbol ">"
        |= variable
            { start = always True
            , inner = (/=) '\n'
            , reserved = Set.fromList []
            }



-- Bold & Italic


bold : List (Parser Token) -> Parser Token
bold tryInside =
    succeed Bold
        |. symbol "**"
        |= tokens
            { try = tryInside
            , stopAt = symbol "**"
            }


oneAsterisk : Parser String
oneAsterisk =
    succeed (identity << (++) "*")
        |. symbol "*"
        |= notChar '*'


italic : List (Parser Token) -> Parser Token
italic tryInside =
    succeed Italic
        |. symbol "__"
        |= tokens
            { try = tryInside
            , stopAt = symbol "__"
            }


oneUnderscore : Parser String
oneUnderscore =
    succeed (identity << (++) "_")
        |. symbol "_"
        |= notChar '_'



-- Code


code : Parser Token
code =
    succeed (codeFromString << String.concat)
        |. symbol "```"
        |= tokens
            { try =
                [ backtrackable oneGrave
                , backtrackable twoGraves
                , variable
                    { start = (/=) '`'
                    , inner = (/=) '`'
                    , reserved = Set.empty
                    }
                ]
            , stopAt = symbol "```"
            }


codeFromString : String -> Token
codeFromString str =
    if Regex.contains regexMultilinePrefix str then
        Code
            (str
                |> Regex.replace regexMultilinePrefix (always "")
                >> Regex.replace regexTrailingWhitespaces (always "")
            )

    else
        CodeInline
            (str
                |> Regex.replace regexTrailingWhitespaces (always "")
            )


regexMultilinePrefix : Regex
regexMultilinePrefix =
    Regex.fromString "^\\s*\n" |> Maybe.withDefault Regex.never


regexTrailingWhitespaces : Regex
regexTrailingWhitespaces =
    Regex.fromString "\\s*$" |> Maybe.withDefault Regex.never


oneGrave : Parser String
oneGrave =
    succeed (identity << (++) "`")
        |. symbol "`"
        |= notChar '`'


twoGraves : Parser String
twoGraves =
    succeed (identity << (++) "``")
        |. symbol "``"
        |= notChar '`'



-- References


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



-- Helper


notChar : Char -> Parser String
notChar c =
    variable
        { start = (/=) c
        , inner = always False
        , reserved = Set.empty
        }
