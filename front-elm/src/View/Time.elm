module View.Time exposing (view)

import Html exposing (..)
import Time exposing (Month(..))


view ts =
    let
        posixTime =
            Time.millisToPosix ts

        day =
            Time.toDay Time.utc posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        month =
            Time.toMonth Time.utc posixTime
                |> toMonthName

        year =
            Time.toYear Time.utc posixTime
                |> String.fromInt

        hours =
            Time.toHour Time.utc posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        minutes =
            Time.toMinute Time.utc posixTime
                |> String.fromInt
                >> String.pad 2 '0'

        seconds =
            Time.toSecond Time.utc posixTime
                |> String.fromInt
                >> String.pad 2 '0'
    in
    text <| String.concat [ day, " ", month, " ", year, "  ", hours, ":", minutes, ":", seconds, " UTC" ]


toMonthName : Month -> String
toMonthName month =
    case month of
        Jan ->
            "Jan"

        Feb ->
            "Feb"

        Mar ->
            "Mar"

        Apr ->
            "Apr"

        May ->
            "May"

        Jun ->
            "Jun"

        Jul ->
            "Jul"

        Aug ->
            "Aug"

        Sep ->
            "Sep"

        Oct ->
            "Oct"

        Nov ->
            "Nov"

        Dec ->
            "Dec"
