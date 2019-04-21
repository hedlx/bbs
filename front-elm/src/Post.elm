module Post exposing
    ( Post
    , decoder
    , mapMedia
    , toggleMediaPreview
    , viewBody
    , viewButtonHead
    , viewHeadElement
    , viewName
    , viewPostTime
    , viewTime
    )

import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import List.Extra
import Media exposing (Media)
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Time exposing (Month(..), Zone)
import Url.Builder


type alias Post =
    { no : Int
    , name : String
    , trip : String
    , text : String
    , ts : Int
    , media : List Media
    }


mapMedia : String -> (Media -> Media) -> Post -> Post
mapMedia mediaID f post =
    { post | media = List.Extra.updateIf (.id >> (==) mediaID) f post.media }


toggleMediaPreview : String -> Post -> Post
toggleMediaPreview mediaID =
    mapMedia mediaID Media.togglePreview


decoder : Decoder Post
decoder =
    Decode.map6 Post
        (Decode.field "no" Decode.int)
        (DecodeExt.withDefault "Anonymous" <| Decode.field "name" Decode.string)
        (DecodeExt.withDefault "" <| Decode.field "trip" Decode.string)
        (Decode.field "text" (Decode.oneOf [ Decode.string, Decode.null "" ]))
        (Decode.field "ts" Decode.int)
        (Decode.field "media" (Decode.list Media.decoder))


viewName : Theme -> Post -> Html msg
viewName theme post =
    let
        htmlTrip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ class theme.fgPostTrip ] [ text ("!" ++ post.trip) ]

        htmlName =
            span [ class theme.fgPostName, class T.dib ] [ text <| String.left 32 post.name ]
    in
    viewHeadElement [] [ htmlName, htmlTrip ]


viewPostTime : Maybe Zone -> Post -> Html msg
viewPostTime maybeZone post =
    viewHeadElement [] [ viewMaybeTime maybeZone post.ts ]


viewMaybeTime : Maybe Zone -> Int -> Html msg
viewMaybeTime maybeZone ts =
    maybeZone
        |> Maybe.map (viewTime ts)
        >> Maybe.withDefault (text "...")


viewTime : Int -> Zone -> Html msg
viewTime ts zone =
    let
        posixTime =
            Time.millisToPosix (1000 * ts)

        day =
            Time.toDay zone posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        month =
            Time.toMonth zone posixTime
                |> toMonthName

        year =
            Time.toYear zone posixTime
                |> String.fromInt

        hours =
            Time.toHour zone posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        minutes =
            Time.toMinute zone posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        seconds =
            Time.toSecond zone posixTime
                |> String.fromInt
                >> String.pad 2 '0'
    in
    text (String.concat [ year, "-", month, "-", day, " ", hours, ":", minutes, ":", seconds ])


toMonthName : Month -> String
toMonthName month =
    case month of
        Jan ->
            "01"

        Feb ->
            "02"

        Mar ->
            "03"

        Apr ->
            "04"

        May ->
            "05"

        Jun ->
            "06"

        Jul ->
            "07"

        Aug ->
            "08"

        Sep ->
            "09"

        Oct ->
            "10"

        Nov ->
            "11"

        Dec ->
            "12"


viewBody toMsg theme threadID post =
    let
        style =
            classes [ T.pa1, T.overflow_hidden, T.pre, theme.fgPost, theme.bgPost ]
    in
    div
        [ style
        , Html.Attributes.style "white-space" "pre-wrap"
        , Html.Attributes.style "word-wrap" "break-word"
        ]
        [ viewListMedia toMsg threadID post.no post.media
        , text post.text
        ]


viewHeadElement attrs =
    div <| [ classes [ T.dib, T.mr2 ] ] ++ attrs


viewButtonHead theme btnText =
    viewHeadElement
        []
        [ span [ class theme.fgButton ] [ text "[" ]
        , span [ classes [ T.underline, T.dim, theme.fgButton ] ] [ text btnText ]
        , span [ class theme.fgButton ] [ text "]" ]
        ]


viewListMedia toMsg threadID postNo listMedia =
    let
        style =
            classes [ T.fl, T.flex, T.flex_wrap ]
    in
    div [ style ] <|
        List.map (viewMedia toMsg threadID postNo) listMedia


viewMedia toMsg threadID postNo media =
    let
        image =
            if media.isPreview then
                viewMediaPreview media

            else
                viewMediaFull media
    in
    a
        [ href <| Media.url media
        , onClick <| toMsg.onMediaClicked threadID postNo media.id
        ]
        [ image ]


viewMediaPreview media =
    let
        urlPreview =
            Url.Builder.crossOrigin Env.urlThumb [ media.id ] []

        computeSizes big small attrBig attrSmall =
            let
                pBig =
                    Basics.min 200 big

                pSmall =
                    round <| toFloat pBig * (toFloat small / toFloat big)
            in
            [ attrBig pBig, attrSmall pSmall ]

        attrsSizes =
            if media.width >= media.height then
                computeSizes media.width media.height width height

            else
                computeSizes media.height media.width height width
    in
    img
        (attrsSizes
            ++ [ stylePostMedia
               , src <| Media.urlPreview media
               ]
        )
        []


viewMediaFull media =
    div []
        [ img
            [ stylePostMedia
            , src <| Media.url media
            ]
            []
        ]


stylePostMedia =
    classes [ T.br1, T.mr3, T.mt1, T.pointer, T.mw_100 ]
