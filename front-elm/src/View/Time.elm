module View.Time exposing (view)

import Html exposing (..)
import Time exposing (Month(..))


view ts =
    let
        posixTime =
            Time.millisToPosix (1000 * ts)

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
