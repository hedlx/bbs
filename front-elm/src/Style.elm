module Style exposing
    ( buttonEnabled
    , buttonIconic
    , content
    , contentNoScroll
    , flexFill
    , textButton
    )

import Html exposing (Attribute)
import Tachyons exposing (classes)
import Tachyons.Classes exposing (..)
import Theme exposing (Theme)


buttonEnabled : Theme -> Attribute msg
buttonEnabled theme =
    classes [ pointer, bg_animate, theme.bgButtonHover ]


flexFill : Attribute msg
flexFill =
    classes [ flex_grow_1 ]


buttonIconic : Attribute msg
buttonIconic =
    classes [ bg_transparent, b__none, outline_0, pointer ]


content : Attribute msg
content =
    classes [ ml5, pa3, min_vh_100, pr4, overflow_x_hidden, overflow_y_visible ]


contentNoScroll : Attribute msg
contentNoScroll =
    classes [ vh_100 ]


textButton : Theme -> Attribute msg
textButton theme =
    classes [ b__solid, pa2, br1, outline_0, theme.bInput ]
