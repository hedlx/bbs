module View.Icons exposing (add, hedlx, search, settings)

import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Encode as Encode
import Octicons
import View.Icons.HedlxSvg as HedlxSvg


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


hedlx =
    HedlxSvg.icon
