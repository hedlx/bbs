module Style exposing
    ( button
    , buttonDisabled
    , buttonEnabled
    , buttonIconic
    , content
    , contentNoScroll
    , flexFiller
    , textButton
    )

import Html exposing (Attribute)
import Tachyons exposing (classes)
import Tachyons.Classes exposing (..)
import Theme exposing (Theme)


button : Theme -> Bool -> Attribute msg
button theme isEnabled =
    if isEnabled then
        buttonEnabled theme

    else
        buttonDisabled theme


buttonEnabled : Theme -> Attribute msg
buttonEnabled theme =
    classes [ pointer, dim, theme.bgButton, theme.fgButton ]


buttonDisabled : Theme -> Attribute msg
buttonDisabled theme =
    classes [ theme.bgButtonDisabled, theme.fgButtonDisabled ]


flexFiller : Attribute msg
flexFiller =
    classes [ flex_grow_1 ]


buttonIconic : Attribute msg
buttonIconic =
    classes [ bg_transparent, b__none, outline_0 ]


content : Attribute msg
content =
    classes [ ml5, pa3, min_vh_100, pr4, overflow_x_hidden, overflow_y_visible ]


contentNoScroll : Attribute msg
contentNoScroll =
    classes [ vh_100 ]


textButton : Theme -> Attribute msg
textButton theme =
    classes [ b__solid, pa2, br1, outline_0, theme.bInput ]
