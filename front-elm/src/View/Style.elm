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
    , content : Attr
    , alert : Attr
    , threadPreview : Attr
    , threadForm : Attr
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
    , textButton : Attr
    , textButtonEnabled : Attr
    , textButtonDisabled : Attr
    , iconicButton : Attr
    , iconicButtonLink : Attr
    , flexFiller : Attr
    , formContainer : Attr
    , formMetaPane : Attr
    , formBodyPane : Attr
    , formMetaElement : Attr
    , formButton : Attr
    , textInput : Attr
    , textArea : Attr
    }


none : Attribute Msg
none =
    Html.Attributes.attribute "" ""


fromTheme : Theme -> Style
fromTheme theme =
    { page = classes [ w_100, h_100, overflow_hidden, theme.bg, theme.fg, theme.font ]
    , menu = classes [ pa0, fl, h_100, w3, flex, flex_column, items_center, theme.bgMenu ]
    , content = classes [ pa3, h_100, overflow_x_hidden, overflow_y_auto ]
    , alert = classes [ theme.fgAlert ]
    , threadPreview = classes [ pa1 ]
    , threadForm = classes [ pa3 ]
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
    , textButton = classes <| [ b__solid, pa2, br1, outline_0, theme.bInput ]
    , textButtonEnabled = classes [ dim, pointer, theme.bgButton, theme.fgButton ]
    , textButtonDisabled = classes [ theme.bgButtonDisabled, theme.fgButtonDisabled ]
    , iconicButton = classes [ bg_transparent, b__none, dim, pt3, pb3, outline_0, theme.fgButton ]
    , iconicButtonLink = classes [ pointer, bg_transparent, b__none, dim, pt3, pb3, outline_0, theme.fgButton ]
    , flexFiller = classes [ flex_grow_1 ]
    , formContainer = classes [ h_100, w_100, flex, flex_row ]
    , formMetaPane = classes [ pl3, pr3, flex, flex_column ]
    , formBodyPane = classes [ pl3, pr3, flex_grow_1, flex, flex_column ]
    , formMetaElement = classes [ db, mb3, w_100 ]
    , formButton = classes [ mt3, mb4 ]
    , textInput = classes [ pa1, br1, b__solid, theme.fgInput, theme.bgInput, theme.bInput ]
    , textArea = classes [ pa1, br1, b__solid, bw1, w_100, theme.fgInput, theme.bgInput, theme.bInput ]
    }
