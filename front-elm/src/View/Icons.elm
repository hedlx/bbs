module View.Icons exposing (add, delete, hedlx, search, settings, spinner)

import Html exposing (..)
import Html.Attributes exposing (..)
import Octicons
import View.Icons.HedlxSvg as HedlxSvg
import View.Icons.SpinnerSvg as SpinnerSvg


options =
    Octicons.defaultOptions
        |> Octicons.size 32
        >> Octicons.color "currentColor"


search =
    Octicons.search options


settings =
    Octicons.gear options


add =
    Octicons.plus options


delete =
    Octicons.trashcan options


hedlx =
    HedlxSvg.icon


spinner size =
    SpinnerSvg.icon size -1.0 11
