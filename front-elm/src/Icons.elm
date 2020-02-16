module Icons exposing (add, close, delete, logo, reset, search, settings, spinner)

import Html exposing (..)
import Html.Attributes exposing (..)
import Icons.SpinnerSvg as SpinnerSvg
import Octicons
import Svg
import Svg.Attributes


options : Octicons.Options
options =
    Octicons.defaultOptions
        |> Octicons.color "currentColor"


search : Int -> Html msg
search size =
    Octicons.search (Octicons.size size options)


settings : Int -> Html msg
settings size =
    Octicons.gear (Octicons.size size options)


add : Int -> Html msg
add size =
    Octicons.plus (Octicons.size size options)


delete : Int -> Html msg
delete size =
    Octicons.trashcan (Octicons.size size options)


close : Int -> Html msg
close size =
    Octicons.x (Octicons.size size options)


reset : Int -> Html msg
reset size =
    Octicons.sync (Octicons.size size options)


logo : Int -> Html msg
logo size =
    Svg.svg
        [ width size, height size, Svg.Attributes.fill "currentColor" ]
        [ Svg.use [ attribute "href" "icons/logo.svg#content" ] [] ]


spinner : Float -> Html msg
spinner size =
    SpinnerSvg.icon size -1.0 11
