module Post exposing
    ( EventHandlers
    , No
    , Op
    , Post
    , decoder
    , mapMedia
    , toggleMediaPreview
    , view
    , viewOp
    )

import Config exposing (Config)
import Env
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.Extra exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import List.Extra
import Media exposing (Media)
import Route
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Theme exposing (Theme)
import Time exposing (Month(..), Zone)
import Url.Builder


type alias Post =
    { no : No
    , name : String
    , trip : String
    , text : String
    , ts : Int
    , media : List Media
    }


type alias Op =
    { threadID : ThreadID
    , subject : Maybe String
    , post : Post
    }


type alias No =
    Int


type alias EventHandlers msg =
    { onMediaClicked : ThreadID -> No -> Media.ID -> msg
    , onReplyToClicked : ThreadID -> No -> msg
    }


type alias ThreadID =
    Int


mapMedia : Media.ID -> (Media -> Media) -> Post -> Post
mapMedia mediaID f post =
    { post | media = List.Extra.updateIf (.id >> (==) mediaID) f post.media }


toggleMediaPreview : Media.ID -> Post -> Post
toggleMediaPreview mediaID =
    mapMedia mediaID Media.togglePreview


decoder : Decoder Post
decoder =
    Decode.map6 Post
        (Decode.field "no" Decode.int)
        (DecodeExt.withDefault Env.defaultName <| Decode.field "name" Decode.string)
        (DecodeExt.withDefault "" <| Decode.field "trip" Decode.string)
        (Decode.field "text" (Decode.oneOf [ Decode.string, Decode.null "" ]))
        (Decode.field "ts" Decode.int)
        (Decode.field "media" (Decode.list Media.decoder))


view : EventHandlers msg -> Config -> ThreadID -> Post -> Html msg
view eventHandlers cfg threadID post =
    let
        theme =
            cfg.theme

        style =
            classes [ T.mb2, T.mb3_ns, T.pa2, T.br1, theme.bgPost ]
    in
    article [ style ]
        [ viewPostHead eventHandlers cfg threadID post
        , viewBody eventHandlers theme threadID post
        ]


viewPostHead : EventHandlers msg -> Config -> ThreadID -> Post -> Html msg
viewPostHead eventHandlers { theme, timeZone } threadID post =
    let
        style =
            classes
                [ T.f6
                , T.overflow_hidden
                , T.pa1
                , theme.fgPostHead
                , theme.fontMono
                , theme.bgPost
                ]
    in
    header [ style ]
        [ viewPostNo eventHandlers theme threadID post
        , viewName theme post
        , viewPostTime timeZone post
        ]


viewPostNo : EventHandlers msg -> Theme -> ThreadID -> Post -> Html msg
viewPostNo eventHandlers theme threadID post =
    viewHeadElement
        [ classes [ T.link, T.pointer, theme.fgPostNo ]
        , onClick <| eventHandlers.onReplyToClicked threadID post.no
        ]
        [ text ("#" ++ String.fromInt post.no) ]


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


viewBody : EventHandlers msg -> Theme -> ThreadID -> Post -> Html msg
viewBody eventHandlers theme threadID post =
    let
        style =
            classes [ T.pa1, T.overflow_hidden, T.pre, theme.fgPost, theme.bgPost ]
    in
    section
        [ style
        , Html.Attributes.style "white-space" "pre-wrap"
        , Html.Attributes.style "word-wrap" "break-word"
        ]
        [ viewListMedia eventHandlers threadID post.no post.media
        , text post.text
        ]


viewHeadElement : List (Attribute msg) -> List (Html msg) -> Html msg
viewHeadElement attrs =
    div <| [ classes [ T.dib, T.mr2 ] ] ++ attrs


viewButtonHead : Theme -> String -> Html msg
viewButtonHead theme btnText =
    viewHeadElement
        []
        [ span [ class theme.fgTextButton ] [ text "[" ]
        , span [ classes [ T.underline, T.dim, theme.fgTextButton ] ] [ text btnText ]
        , span [ class theme.fgTextButton ] [ text "]" ]
        ]


viewListMedia : EventHandlers msg -> ThreadID -> No -> List Media -> Html msg
viewListMedia eventHandlers threadID postNo listMedia =
    let
        style =
            classes [ T.fl, T.flex, T.flex_wrap ]
    in
    div [ style ] <|
        List.map (viewMedia eventHandlers threadID postNo) listMedia


viewMedia : EventHandlers msg -> ThreadID -> No -> Media -> Html msg
viewMedia eventHandlers threadID postNo media =
    let
        image =
            if media.isPreview then
                viewMediaPreview media

            else
                viewMediaFull media
    in
    a
        [ href <| Media.url media
        , onClick <| eventHandlers.onMediaClicked threadID postNo media.id
        ]
        [ image ]


viewMediaPreview : Media -> Html msg
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
               , alt "[Attached media]"
               ]
        )
        []


viewMediaFull : Media -> Html msg
viewMediaFull media =
    div []
        [ img
            [ stylePostMedia
            , src <| Media.url media
            , alt "[Attached media]"
            ]
            []
        ]


stylePostMedia : Attribute msg
stylePostMedia =
    classes [ T.br1, T.mr3, T.mt1, T.pointer, T.mw_100 ]



-- OP-post functions


viewOp : EventHandlers msg -> Config -> Op -> Html msg
viewOp eventHandlers cfg op =
    let
        theme =
            cfg.theme

        style =
            classes [ T.mb2, T.mb3_ns, T.pa2, T.br1, theme.bgPost ]
    in
    article [ style ]
        [ viewOpHead eventHandlers cfg op
        , viewBody eventHandlers theme op.threadID op.post
        ]


viewOpHead : EventHandlers msg -> Config -> Op -> Html msg
viewOpHead eventHandlers { theme, timeZone } { threadID, subject, post } =
    let
        style =
            classes
                [ T.f6
                , T.overflow_hidden
                , T.pa1
                , theme.fgPostHead
                , theme.fontMono
                , theme.bgPost
                ]

        subjectOrNothing =
            Maybe.map (viewSubject theme threadID) subject
                |> Maybe.withDefault nothing
    in
    header [ style ]
        [ viewOpNo theme threadID
        , subjectOrNothing
        , viewName { theme | fgPostName = theme.fgOpName } post
        , viewPostTime timeZone post
        , viewReply eventHandlers theme threadID
        , viewShowAll theme threadID
        ]


viewOpNo : Theme -> ThreadID -> Html msg
viewOpNo theme threadID =
    viewThreadLink threadID [ viewButtonHead theme (String.fromInt threadID) ]


viewReply : EventHandlers msg -> Theme -> ThreadID -> Html msg
viewReply eventHandlers theme threadID =
    span
        [ classes [ T.link, T.pointer ]
        , onClick <| eventHandlers.onReplyToClicked threadID 0
        ]
        [ viewButtonHead theme "Reply" ]


viewShowAll : Theme -> ThreadID -> Html msg
viewShowAll theme threadID =
    viewThreadLink threadID [ viewButtonHead theme "Show All" ]


viewSubject : Theme -> ThreadID -> String -> Html msg
viewSubject theme threadID subject =
    let
        style =
            classes [ T.f4, T.link, T.pointer, theme.fgThreadSubject ]
    in
    viewThreadLink threadID <|
        [ viewHeadElement
            [ style ]
            [ text subject ]
        ]


viewThreadLink : ThreadID -> List (Html msg) -> Html msg
viewThreadLink threadID =
    a [ href <| Route.internalLink [ String.fromInt threadID ] ]
