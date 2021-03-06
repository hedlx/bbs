module Post exposing
    ( EventHandlers
    , EventHandlersOP
    , No
    , Op
    , Post
    , decoder
    , domID
    , domIDBtnNext
    , domIDBtnPrev
    , domIDOp
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
import Post.Text exposing (Text)
import Route
import String.Format as StrF
import Tachyons exposing (classes)
import Tachyons.Classes as T
import Tachyons.Classes.Extra as TE
import Theme exposing (Theme)
import Time exposing (Month(..), Zone)
import Url.Builder


type alias Post =
    { no : No
    , name : String
    , trip : String
    , text : Text
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


type alias EventHandlers msg a =
    { a
        | onMediaClicked : ThreadID -> No -> Media.ID -> msg
        , onReplyToClicked : ThreadID -> No -> msg
    }


type alias EventHandlersOP msg =
    EventHandlers msg
        { onNextThreadClicked : Maybe (ThreadID -> msg)
        , onPrevThreadClicked : Maybe (ThreadID -> msg)
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
        (Decode.field "text" Post.Text.decoder)
        (Decode.field "ts" Decode.int)
        (Decode.field "media" (Decode.list Media.decoder))



-- Regular Post


domID : Int -> Int -> String
domID threadID postNo =
    "post-{{ }}-{{ }}"
        |> StrF.value (String.fromInt threadID)
        >> StrF.value (String.fromInt postNo)


view : EventHandlers msg a -> Config -> ThreadID -> Bool -> Post -> Html msg
view eventHandlers cfg threadID isFocused post =
    let
        theme =
            cfg.theme
    in
    article
        [ id (domID threadID post.no)
        , stylePost isFocused theme
        ]
        [ viewHead eventHandlers cfg threadID post
        , viewBody eventHandlers cfg threadID post
        ]


stylePost : Bool -> Theme -> Attribute msg
stylePost isFocused theme =
    classes
        ([ T.mb1
         , T.mb2_ns
         , T.br3
         , T.br4_ns
         , T.overflow_hidden
         , theme.bgPost
         , T.b__solid
         ]
            ++ (if isFocused then
                    [ theme.bFocusedPost ]

                else
                    [ T.b__transparent ]
               )
        )



-- Post Head


viewHead : EventHandlers msg a -> Config -> ThreadID -> Post -> Html msg
viewHead eventHandlers cfg threadID post =
    header [ stylePostHead cfg.theme ]
        (viewHeadElements eventHandlers cfg threadID post)


viewHeadElements : EventHandlers msg a -> Config -> ThreadID -> Post -> List (Html msg)
viewHeadElements eventHandlers { theme, timeZone } threadID post =
    [ viewNo eventHandlers theme threadID post
    , viewName theme post
    , viewPostTime timeZone post
    ]


stylePostHead : Theme -> Attribute msg
stylePostHead theme =
    classes
        [ T.f7
        , T.f6_ns
        , T.overflow_hidden
        , T.pb1
        , T.pl2
        , T.pl3_ns
        , theme.fgPostHead
        , theme.fontMono
        ]


viewNo : EventHandlers msg a -> Theme -> ThreadID -> Post -> Html msg
viewNo eventHandlers theme threadID post =
    viewHeadElement
        [ classes [ T.link, T.pointer, TE.sel_none, theme.fgPostNo ]
        , onClick (eventHandlers.onReplyToClicked threadID post.no)
        ]
        [ text ("#" ++ String.fromInt post.no) ]


viewName : Theme -> Post -> Html msg
viewName theme post =
    let
        htmlTrip =
            if String.isEmpty post.trip then
                nothing

            else
                span [ classes [ theme.fgPostTrip ] ]
                    [ text ("!" ++ post.trip) ]

        htmlName =
            span [ class theme.fgPostName, class T.dib ]
                [ text (String.left 32 post.name) ]
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
    text <| String.concat [ year, "-", month, "-", day, " ", hours, ":", minutes, ":", seconds ]


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



-- Post Body


viewBody : EventHandlers msg a -> Config -> ThreadID -> Post -> Html msg
viewBody eventHandlers cfg threadID post =
    let
        style =
            classes [ T.overflow_hidden, T.pre ]
    in
    section
        [ style
        , Html.Attributes.style "white-space" "pre-wrap"
        ]
        [ viewListMedia eventHandlers cfg threadID post.no post.media
        , Post.Text.view cfg threadID post.text
        ]


viewHeadElement : List (Attribute msg) -> List (Html msg) -> Html msg
viewHeadElement attrs =
    div (classes [ T.dib, T.mr2, T.mt2 ] :: attrs)


viewHeadButton : (List (Html msg) -> Html msg) -> Theme -> String -> Html msg
viewHeadButton actionWrapper theme btnText =
    viewHeadElement
        [ classes [ T.dim ] ]
        [ actionWrapper
            [ span [ class theme.fgTextButton ] [ text "[" ]
            , span [ classes [ T.underline, theme.fgTextButton ] ] [ text btnText ]
            , span [ class theme.fgTextButton ] [ text "]" ]
            ]
        ]


viewListMedia : EventHandlers msg a -> Config -> ThreadID -> No -> List Media -> Html msg
viewListMedia eventHandlers cfg threadID postNo listMedia =
    let
        style =
            classes [ T.fl, T.mr2, T.mb2, T.mr3_ns, T.mb3_ns, T.flex, T.flex_wrap ]
    in
    div [ style ] <|
        List.map (viewMedia eventHandlers cfg threadID postNo) listMedia


viewMedia : EventHandlers msg a -> Config -> ThreadID -> No -> Media -> Html msg
viewMedia eventHandlers cfg threadID postNo media =
    let
        styleMediaContainer =
            classes [ T.ml2, T.mt2, T.ml3_ns, T.mt3_ns ]

        attrs =
            [ href (Media.url cfg media)
            , onClick (eventHandlers.onMediaClicked threadID postNo media.id)
            , target "_top"
            ]
    in
    if media.isPreview then
        div [ class T.db, styleMediaContainer ]
            [ a attrs [ viewMediaPreview cfg media ] ]

    else
        div [ styleMediaContainer ]
            [ a attrs [ viewMediaFull cfg media ] ]


viewMediaPreview : Config -> Media -> Html msg
viewMediaPreview cfg media =
    let
        urlPreview =
            Url.Builder.crossOrigin cfg.urlThumb [ media.id ] []

        attrsSizes =
            if media.width >= media.height then
                mediaSizes media.width media.height width height

            else
                mediaSizes media.height media.width height width
    in
    img
        (attrsSizes
            ++ [ stylePostMedia
               , src (Media.urlPreview cfg media)
               , alt "[Attached media]"
               ]
        )
        []


mediaSizes : Int -> Int -> (Int -> Attribute msg) -> (Int -> Attribute msg) -> List (Attribute msg)
mediaSizes big small attrBig attrSmall =
    let
        pBig =
            Basics.min 200 big

        pSmall =
            round <| toFloat pBig * (toFloat small / toFloat big)
    in
    [ attrBig pBig, attrSmall pSmall ]


viewMediaFull : Config -> Media -> Html msg
viewMediaFull cfg media =
    img
        [ stylePostMedia
        , width media.width
        , src (Media.url cfg media)
        , alt "[Attached media]"
        ]
        []


stylePostMedia : Attribute msg
stylePostMedia =
    classes [ T.db, T.br1, T.pointer, T.mw_100 ]



-- OP-Post


domIDOp : Int -> String
domIDOp threadID =
    StrF.value (String.fromInt threadID) "post-op-{{ }}"


domIDBtnNext : Int -> String
domIDBtnNext threadID =
    StrF.value (String.fromInt threadID) "btn-next-{{ }}"


domIDBtnPrev : Int -> String
domIDBtnPrev threadID =
    StrF.value (String.fromInt threadID) "btn-prev-{{ }}"


viewOp : EventHandlersOP msg -> Config -> Op -> Html msg
viewOp eventHandlers cfg op =
    let
        theme =
            cfg.theme
    in
    article [ stylePost False theme ]
        [ viewOpHead eventHandlers cfg op
        , viewBody eventHandlers cfg op.threadID op.post
        ]



-- OP-Post Head


viewOpHead : EventHandlersOP msg -> Config -> Op -> Html msg
viewOpHead eventHandlers cfg { threadID, subject, post } =
    let
        theme =
            cfg.theme
    in
    header [ stylePostHead theme ]
        [ div [ classes [ T.pt2 ] ]
            [ viewPrevNextControls eventHandlers theme threadID
            , viewOpNo theme threadID
            , viewSubject theme threadID subject
            , viewReply eventHandlers theme threadID
            , viewShowAll theme threadID
            ]
        , div []
            (viewHeadElements eventHandlers cfg threadID post)
        ]


viewOpNo : Theme -> ThreadID -> Html msg
viewOpNo theme threadID =
    viewHeadButton (viewThreadLink threadID [ class TE.sel_none ])
        theme
        (String.fromInt threadID)


viewPrevNextControls : EventHandlersOP msg -> Theme -> ThreadID -> Html msg
viewPrevNextControls eventHandlers theme threadID =
    span
        [ id (domIDOp threadID)
        , classes [ T.mr2, TE.sel_none ]
        ]
        [ button
            (id (domIDBtnNext threadID)
                :: stylePrevNext
                :: (eventHandlers.onNextThreadClicked
                        |> Maybe.map (\toMsg -> [ onClick (toMsg threadID), stylePrevNextEnabled theme ])
                        >> Maybe.withDefault [ class theme.fgButtonDisabled ]
                   )
            )
            [ text "[▼" ]
        , span [ class theme.fgTextButton ] [ text "|" ]
        , button
            (id (domIDBtnPrev threadID)
                :: stylePrevNext
                :: (eventHandlers.onPrevThreadClicked
                        |> Maybe.map (\toMsg -> [ onClick (toMsg threadID), stylePrevNextEnabled theme ])
                        >> Maybe.withDefault [ class theme.fgButtonDisabled ]
                   )
            )
            [ text "▲]" ]
        ]


stylePrevNextEnabled : Theme -> Attribute msg
stylePrevNextEnabled theme =
    classes [ theme.fgTextButton, T.dim ]


stylePrevNext : Attribute msg
stylePrevNext =
    classes
        [ T.pointer
        , T.outline_transparent
        , T.bg_transparent
        , T.b__none
        , T.pa0
        ]


viewSubject : Theme -> ThreadID -> Maybe String -> Html msg
viewSubject theme threadID subject =
    let
        style =
            classes [ T.f5, T.f4_ns, T.no_underline, T.dim, T.pointer, theme.fgThreadSubject ]

        strSubject =
            Maybe.withDefault ("Thread #" ++ String.fromInt threadID) subject
    in
    viewHeadElement
        []
        [ viewThreadLink threadID [ style ] [ text strSubject ] ]


viewReply : EventHandlersOP msg -> Theme -> ThreadID -> Html msg
viewReply eventHandlers theme threadID =
    viewHeadButton
        (a
            [ classes [ T.bg_transparent, T.pa0, T.b__none, T.no_underline, T.pointer, TE.sel_none ]
            , onClick (eventHandlers.onReplyToClicked threadID 0)
            , href ""
            ]
        )
        theme
        "Reply"


viewShowAll : Theme -> ThreadID -> Html msg
viewShowAll theme threadID =
    viewHeadButton (viewThreadLink threadID [ class TE.sel_none ])
        theme
        "Open"


viewThreadLink : ThreadID -> List (Attribute msg) -> List (Html msg) -> Html msg
viewThreadLink threadID attrs =
    a (href (Route.link (Route.Thread threadID)) :: classes [ T.no_underline ] :: attrs)
