module Tachyons.Classes.Animations exposing (css, fadein_left_ns, fadein_right, fadein_top_s)

import Css exposing (..)
import Css.Animations as Ani exposing (keyframes)
import Css.Global exposing (class, global, media)
import Css.Media as Media exposing (only, screen)
import Html exposing (Html)
import Html.Styled exposing (toUnstyled)



-- DECLARATIONS


fadein_right : String
fadein_right =
    "fadein-right"


fadein_left_ns : String
fadein_left_ns =
    "fadein-left-ns"


fadein_top_s : String
fadein_top_s =
    "fadein-top-s"



-- DEFINITIONS


css : Html msg
css =
    (toUnstyled << Css.Global.global)
        [ class fadein_right
            [ animationName ani__fadein_right
            , animationDuration (Css.sec 0.3)
            ]
        , media [ only screen [ Media.minWidth (em 30) ] ]
            [ class fadein_left_ns
                [ animationName ani__fadein_left_ns
                , animationDuration (Css.sec 0.3)
                ]
            ]
        , media [ only screen [ Media.maxWidth (em 30) ] ]
            [ class fadein_top_s
                [ animationName ani__fadein_top_s
                , animationDuration (Css.sec 0.3)
                ]
            ]
        ]


ani__fadein_right : Ani.Keyframes {}
ani__fadein_right =
    keyframes
        [ ( 0
          , [ Ani.opacity (num 0)
            , Ani.transform [ translateX (px 15) ]
            ]
          )
        , ( 100
          , [ Ani.opacity (num 1)
            , Ani.transform [ translateX (px 0) ]
            ]
          )
        ]


ani__fadein_left_ns : Ani.Keyframes {}
ani__fadein_left_ns =
    keyframes
        [ ( 0
          , [ Ani.opacity (num 0)
            , Ani.transform [ translateX (px -15) ]
            ]
          )
        , ( 100
          , [ Ani.opacity (num 1)
            , Ani.transform [ translateX (px 0) ]
            ]
          )
        ]


ani__fadein_top_s : Ani.Keyframes {}
ani__fadein_top_s =
    keyframes
        [ ( 0
          , [ Ani.opacity (num 0)
            , Ani.transform [ translateY (px -15) ]
            ]
          )
        , ( 100
          , [ Ani.opacity (num 1)
            , Ani.transform [ translateY (px 0) ]
            ]
          )
        ]
