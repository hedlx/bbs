module Post.Text exposing (Text, decoder, isBlank, view)

import Config exposing (Config)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Markdown.Block as MB exposing (Block)
import Markdown.Inline as MI exposing (Inline)
import Regex exposing (Regex)
import String.Extra
import String.Format as StrF
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
                    MI.Text ("\\> " ++ Regex.replace regexNewLine (always "\n\\> ") str)

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
            renderTextWithRefs theme threadID str

        _ ->
            MI.toHtml inline


renderTextWithRefs : Theme -> Int -> String -> Html msg
renderTextWithRefs theme threadID str =
    span []
        (List.concatMap
            (MB.defaultHtml Nothing (Just (renderInlineRefs theme threadID)))
            (MB.parse Nothing (replaceRefs threadID str))
        )


renderInlineRefs : Theme -> Int -> Inline i -> Html msg
renderInlineRefs theme threadID inline =
    case inline of
        MI.Link url maybeTitle inlines ->
            a
                [ href url
                , styleRef theme
                , title (Maybe.withDefault url maybeTitle)
                ]
                [ text "@"
                , span [ class T.underline ]
                    (List.map (renderInlineRefs theme threadID) inlines)
                ]

        _ ->
            MI.toHtml inline


regexRef : Regex
regexRef =
    Regex.fromString "@(\\d+)(/?\\d*)"
        |> Maybe.withDefault Regex.never


replaceRefs : Int -> String -> String
replaceRefs threadID str =
    Regex.replace regexRef
        (\{ match, submatches } ->
            "[{{ }}]({{ }})"
                |> StrF.value (String.dropLeft 1 match)
                >> StrF.value
                    (case submatches of
                        (Just postNo) :: Nothing :: [] ->
                            "#/" ++ String.fromInt threadID ++ "/" ++ postNo

                        (Just tID) :: (Just postNo) :: [] ->
                            "#/" ++ tID ++ postNo

                        _ ->
                            "/404"
                    )
        )
        str


styleRef : Theme -> Html.Attribute msg
styleRef theme =
    classes [ T.link, theme.fontMono, T.f6, T.pointer, T.dim, theme.fgRef ]
