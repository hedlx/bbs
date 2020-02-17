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
            (List.concatMap (renderBlock cfg.theme)
                (MB.parse Nothing (replaceRefs threadID str))
            )


replaceRefs : Int -> String -> String
replaceRefs threadID str =
    Regex.replace regexRef
        (\{ match, submatches } ->
            "[{{ }}]({{ }})"
                |> StrF.value match
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


regexRef : Regex
regexRef =
    Regex.fromString ">>(\\d+)(/?\\d*)"
        |> Maybe.withDefault Regex.never


renderBlock : Theme -> Block b i -> List (Html msg)
renderBlock theme block =
    case block of
        MB.CodeBlock _ str ->
            [ code [ classes [ T.dib, theme.fgCode, theme.bgCode, T.br2, T.f6, T.pa2 ] ]
                [ text str ]
            ]

        MB.BlockQuote subBlocks ->
            [ blockquote [ classes [ theme.fgQuote ] ]
                (List.concatMap (renderBlock theme) subBlocks)
            ]

        MB.Paragraph _ inlines ->
            [ p [] (List.map (renderInline theme) inlines) ]

        _ ->
            MB.toHtml block


renderInline : Theme -> Inline i -> Html msg
renderInline theme inline =
    case inline of
        MI.Link url maybeTitle inlines ->
            a
                [ href url
                , styleRef theme
                , title (Maybe.withDefault url maybeTitle)
                ]
                (List.map (renderInline theme) inlines)

        _ ->
            MI.toHtml inline


styleRef : Theme -> Html.Attribute msg
styleRef theme =
    classes [ T.link, T.pointer, T.dim, T.underline, theme.fgTextButton ]
