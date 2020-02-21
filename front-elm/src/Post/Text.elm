module Post.Text exposing (Text, decoder, isBlank, view)

import Config exposing (Config)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block as MB exposing (Block)
import Markdown.Inline as MI exposing (Inline)
import Parser as P exposing ((|.), (|=), Parser)
import Regex exposing (Regex)
import Set
import String.Extra
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)


type Text
    = Text String


decoder : Decoder Text
decoder =
    Decode.map Text (Decode.oneOf [ Decode.string, Decode.null "" ])


isBlank : Text -> Bool
isBlank (Text str) =
    String.Extra.isBlank str



-- View


view : Config -> Int -> Text -> Html msg
view cfg threadID (Text str) =
    if String.Extra.isBlank str then
        nothing

    else
        div
            [ classes [ T.ma2, T.ma3_ns ]
            , style "max-width" (String.fromInt (Config.maxLineLength cfg) ++ "ch")
            ]
            (List.concatMap (renderBlock cfg.theme threadID) (MB.parse Nothing str))


renderBlock : Theme -> Int -> Block b i -> List (Html msg)
renderBlock theme threadID block =
    case block of
        MB.CodeBlock _ str ->
            [ code [ classes [ T.dib, theme.fgCode, theme.bgCode, T.br2, T.f6, T.pa2 ] ]
                [ text str ]
            ]

        MB.BlockQuote subBlocks ->
            [ blockquote [ classes [ theme.fgQuote, T.ma0 ] ]
                (List.concatMap
                    (renderBlock theme threadID << addGT)
                    subBlocks
                )
            ]

        MB.Paragraph str inlines ->
            MB.defaultHtml Nothing
                (Just (renderInline theme threadID))
                (MB.Paragraph str inlines)

        MB.List listBlock items ->
            MB.defaultHtml (Just (renderBlock theme threadID))
                Nothing
                (MB.List listBlock items)

        MB.PlainInlines inlines ->
            MB.defaultHtml Nothing
                (Just (renderInline theme threadID))
                (MB.PlainInlines inlines)

        _ ->
            MB.toHtml block


addGT : Block b i -> Block b i
addGT =
    MB.walkInlines
        (\inline ->
            case inline of
                MI.Text str ->
                    MI.Text ("> " ++ Regex.replace regexNewLine (always "\n> ") str)

                _ ->
                    inline
        )


regexNewLine : Regex
regexNewLine =
    Regex.fromString "\\n"
        |> Maybe.withDefault Regex.never


renderInline : Theme -> Int -> Inline i -> Html msg
renderInline theme threadID inline =
    case inline of
        MI.Text str ->
            renderText theme threadID str

        MI.Link url maybeTitle inlines ->
            a
                [ href url
                , styleLink theme
                , title (Maybe.withDefault url maybeTitle)
                , class T.underline
                ]
                (List.map (renderInline theme threadID) inlines)

        _ ->
            MI.toHtml inline


renderText : Theme -> Int -> String -> Html msg
renderText theme threadID str =
    span []
        (P.run (parserTextToHtml theme threadID) str
            |> Result.withDefault [ text str ]
        )


parserTextToHtml : Theme -> Int -> Parser (List (Html msg))
parserTextToHtml theme threadID =
    P.loop []
        (\revParsed ->
            P.oneOf
                [ P.succeed (\html -> P.Loop (html :: revParsed))
                    |= P.oneOf
                        [ parserRef theme threadID
                        , parserPlainText theme
                        ]
                , P.succeed ()
                    |> P.map (\_ -> P.Done (List.reverse revParsed))
                ]
        )


parserPlainText : Theme -> Parser (Html msg)
parserPlainText _ =
    P.succeed text
        |= P.variable
            { start = always True
            , inner = (/=) '@'
            , reserved = Set.fromList []
            }


type Ref
    = Ref RefKind String


type RefKind
    = RefPostLocal
    | RefPostGlobal
    | RefThread


parserRef : Theme -> Int -> Parser (Html msg)
parserRef theme threadID =
    P.succeed (renderRef theme threadID)
        |. P.symbol "@"
        |= P.oneOf
            [ P.backtrackable <|
                P.succeed (\tID postNo -> Ref RefPostGlobal (tID ++ "/" ++ postNo))
                    |= parserDigits
                    |. P.symbol "/"
                    |= parserDigits
            , P.backtrackable <|
                P.succeed (Ref RefThread)
                    |= parserDigits
                    |. P.symbol "/"
            , P.backtrackable <|
                P.succeed (Ref RefPostLocal)
                    |= parserDigits
            ]


parserDigits : Parser String
parserDigits =
    P.variable
        { start = Char.isDigit
        , inner = Char.isDigit
        , reserved = Set.fromList []
        }


refToPath : Int -> Ref -> String
refToPath threadID ref =
    case ref of
        Ref RefPostLocal path ->
            "#/" ++ String.fromInt threadID ++ "/" ++ path

        Ref _ path ->
            "#/" ++ path


refToStr : Ref -> String
refToStr ref =
    case ref of
        Ref _ path ->
            "@" ++ path


renderRef : Theme -> Int -> Ref -> Html msg
renderRef theme threadID ref =
    a
        [ href (refToPath threadID ref)
        , styleLink theme
        , classes [ theme.fontMono, T.f6 ]
        ]
        [ text (refToStr ref) ]


styleLink : Theme -> Html.Attribute msg
styleLink theme =
    classes [ T.link, T.pointer, T.dim, theme.fgRef ]
