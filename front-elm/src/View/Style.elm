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
    , buttonEnabled : Attr
    , buttonDisabled : Attr
    , threadPreview : Attr
    , postForm : Attr
    , previewPosts : Attr
    , threadNo : Attr
    , threadSubject : Attr
    , postNo : Attr
    , op : Attr
    , thread : Attr
    , post : Attr
    , postHead : Attr
    , postHeadElement : Attr
    , postName : Attr
    , opName : Attr
    , postTrip : Attr
    , postBody : Attr
    , fgButton : Attr
    , textButton : Attr
    , iconicButton : Attr
    , menuButton : Attr
    , flexFiller : Attr
    , formContainer : Attr
    , formMetaPane : Attr
    , formBodyPane : Attr
    , formElement : Attr
    , formButton : Attr
    , formProblems : Attr
    , textInput : Attr
    , textArea : Attr
    , hypertextLink : Attr
    , replyForm : Attr
    }


none : Attribute Msg
none =
    Html.Attributes.attribute "" ""


fromTheme : Theme -> Style
fromTheme theme =
    let
        iconicButton =
            [ bg_transparent, b__none, outline_0 ]
    in
    { page = classes [ w_100, h_100, overflow_hidden, theme.bg, theme.fg, theme.font ]
    , menu = classes [ pa0, fl, h_100, w3, flex, flex_column, items_center, theme.bgMenu ]
    , content = classes [ pa3, h_100, overflow_x_hidden, overflow_y_auto ]
    , alert = classes [ theme.fgAlert ]
    , buttonEnabled = classes [ pointer, dim, theme.bgButton, theme.fgButton ]
    , buttonDisabled = classes [ theme.bgButtonDisabled, theme.fgButtonDisabled ]
    , threadPreview = classes []
    , postForm = classes [ pa3 ]
    , previewPosts = classes [ pl5 ]
    , threadNo = classes [ theme.fgThreadNo ]
    , threadSubject = classes [ f4, theme.fgThreadSubject ]
    , postNo = classes [ theme.fgPostNo ]
    , op = classes [ pa1 ]
    , thread = classes []
    , post = classes [ mb3, pa2, br1, theme.bgPost ]
    , postHead = classes [ f6, overflow_hidden, pa1, theme.fgPostHead, theme.fontMono, theme.bgPost ]
    , postHeadElement = classes [ dib, mr2 ]
    , postName = classes [ dib, theme.fgPostName ]
    , opName = classes [ theme.fgOpName ]
    , postTrip = classes [ theme.fgPostTrip ]
    , postBody = classes [ pa1, overflow_hidden, pre, theme.fgPost, theme.bgPost ]
    , fgButton = classes [ theme.fgButton ]
    , textButton = classes [ b__solid, pa2, br1, outline_0, theme.bInput ]
    , iconicButton = classes iconicButton
    , menuButton = classes <| iconicButton ++ [ pa3 ]
    , flexFiller = classes [ flex_grow_1 ]
    , formContainer = classes [ h_100, w_100, flex, flex_row ]
    , formMetaPane = classes [ pl3, pr3, flex, flex_column ]
    , formBodyPane = classes [ pl3, pr3, flex_grow_1, flex, flex_column ]
    , formElement = classes [ db, mb3, w_100 ]
    , formButton = classes [ mt3, mb4 ]
    , formProblems = classes [ h3 ]
    , textInput = classes [ pa1, br1, b__solid, theme.fgInput, theme.bgInput, theme.bInput ]
    , textArea = classes [ pa1, br1, b__solid, bw1, w_100, theme.fgInput, theme.bgInput, theme.bInput ]
    , hypertextLink = classes [ underline, theme.fgButton, dim ]
    , replyForm = classes [ mt4 ]
    }
