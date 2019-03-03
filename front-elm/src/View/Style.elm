module View.Style exposing (Style, fromTheme)

import Html exposing (Attribute)
import Html.Attributes
import Model.Theme exposing (Theme)
import Msg exposing (Msg)
import Tachyons exposing (classes, tachyons)
import Tachyons.Classes exposing (..)


type alias Attr =
    Attribute Msg


type alias Style =
    { page : Attr
    , menu : Attr
    , threads : Attr
    , threadPreview : Attr
    , previewPosts : Attr
    , op : Attr
    , opHead : Attr
    , opName : Attr
    , opTrip : Attr
    , opBody : Attr
    , post : Attr
    , postHead : Attr
    , postName : Attr
    , postTrip : Attr
    , postBody : Attr
    , iconicButton : Attr
    , iconicButtonLink : Attr
    , flexFiller : Attr
    }


none : Attribute Msg
none =
    Html.Attributes.attribute "" ""


fromTheme : Theme -> Style
fromTheme theme =
    { page = classes [ w_100, h_100, overflow_hidden, theme.bg, theme.fg, theme.font ]
    , menu = classes [ pa0, fl, h_100, w3, flex, flex_column, items_center, theme.bgMenu ]
    , threads = classes [ pa3, h_100, overflow_x_hidden, overflow_y_scroll ]
    , threadPreview = classes [ pa1 ]
    , previewPosts = classes [ pa3 ]
    , op = classes [ pa1 ]
    , opHead = classes [ pa1, theme.fgPostHead, theme.bgPost ]
    , opName = classes [ theme.fgOpName ]
    , opTrip = classes [ f6, theme.fontMono, theme.fgPostTrip ]
    , opBody = classes [ pa1, theme.fgPost, theme.bgPost ]
    , post = classes [ pa2, br1, theme.bgPost ]
    , postHead = classes [ pa1, theme.fgPostHead, theme.bgPost ]
    , postName = classes [ theme.fgPostName ]
    , postTrip = classes [ f6, theme.fontMono, theme.fgPostTrip ]
    , postBody = classes [ pa1, theme.fgPost, theme.bgPost ]
    , iconicButton = classes [ bg_transparent, b__none, dim, pt3, pb3, outline_0, theme.fgButton ]
    , iconicButtonLink = classes [ pointer, bg_transparent, b__none, dim, pt3, pb3, outline_0, theme.fgButton ]
    , flexFiller = classes [ flex_grow_1 ]
    }
