module Icons exposing (add, delete, hedlx, search, settings, spinner)

import Html exposing (..)
import Html.Attributes exposing (..)
import Icons.HedlxSvg as HedlxSvg
import Icons.SpinnerSvg as SpinnerSvg
import Octicons


options : Octicons.Options
options =
    Octicons.defaultOptions
        |> Octicons.size 32
        >> Octicons.color "currentColor"


search : Html msg
search =
    Octicons.search options


settings : Html msg
settings =
    Octicons.gear options


add : Html msg
add =
    Octicons.plus options


delete : Html msg
delete =
    Octicons.trashcan options


hedlx : Html msg
hedlx =
    HedlxSvg.icon


spinner : Float -> Html msg
spinner size =
    SpinnerSvg.icon size -1.0 11
