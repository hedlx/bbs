module Style.Extra exposing (css, sel_none)

import Css exposing (..)
import Css.Global exposing (class, global)
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)



-- DECLARATIONS


sel_none : String
sel_none =
    "select-none"



-- DEFINITIONS


css : Html msg
css =
    (toUnstyled << Css.Global.global)
        [ class sel_none
            [ property "-webkit-user-select" "none"
            , property "-moz-user-select" "none"
            , property "-ms-user-select" "none"
            , property "user-select" "none"
            ]
        ]
