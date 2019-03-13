module View.Time exposing (view)

import Html exposing (..)
import Msg exposing (Msg)
import Time exposing (Month(..), Zone)


view : Maybe Zone -> Int -> Html Msg
view maybeZone ts =
    maybeZone
        |> Maybe.map (view_ ts)
        >> Maybe.withDefault (text "...")


view_ ts zone =
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
