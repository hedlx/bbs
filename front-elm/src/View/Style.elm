module View.Style exposing (Style, fromTheme)

import Html exposing (Attribute)
import Model.Theme exposing (Theme)
import Msg exposing (Msg)
import Tachyons exposing (classes)
import Tachyons.Classes exposing (..)
import View.Style.Animations exposing (fadein_r)


type alias Attr =
    Attribute Msg


type alias Style =
    { page : Attr
    , menu : Attr
    , content : Attr
    , contentNoScroll : Attr
    , alert : Attr
    , notFound : Attr
    , spinner : Attr
    , popUpStack : Attr
    , popUp : Attr
    , popUpWarn : Attr
    , popUpErr : Attr
    , buttonEnabled : Attr
    , buttonDisabled : Attr
    , threadPreview : Attr
    , postForm : Attr
    , previewPosts : Attr
    , threadNo : Attr
    , threadSubject : Attr
    , threadSubjectBig : Attr
    , postNo : Attr
    , op : Attr
    , thread : Attr
    , post : Attr
    , postHead : Attr
    , postHeadElement : Attr
    , postName : Attr
    , postMediaPreviewContainer : Attr
    , postMediaPreview : Attr
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
    , formAreaAttachedFiles : Attr
    , formMediaPreview : Attr
    , formMediaPreviewOverlay : Attr
    , formButtonAddImage : Attr
    , formProblems : Attr
    , textInput : Attr
    , textArea : Attr
    , hypertextLink : Attr
    , replyForm : Attr
    }


fromTheme : Theme -> Style
fromTheme theme =
    let
        iconicButton =
            [ bg_transparent, b__none, outline_0 ]
    in
    { page = classes [ w_100, min_vh_100, theme.bg, theme.fg, theme.font ]
    , menu = classes [ fixed, pa0, fl, h_100, w3, flex, flex_column, items_center, theme.bgMenu ]
    , content = classes [ ml5, pa3, min_vh_100, pr4, overflow_x_hidden, overflow_y_visible ]
    , contentNoScroll = classes [ vh_100 ]
    , alert = classes [ theme.fgAlert ]
    , notFound = classes [ f1, tc ]
    , spinner = classes [ theme.fgSpinner ]
    , popUpStack = classes [ fixed, w_30, right_0, ma0, pa3, z_max, br3, fr, list, theme.font ]
    , popUp = classes [ pl3, pr3, pt1, pb1, ma2, br1, fadein_r, dim, pointer ]
    , popUpWarn = classes [ theme.fgPopUpWarn, theme.bgPopUpWarn ]
    , popUpErr = classes [ theme.fgPopUpErr, theme.bgPopUpErr ]
    , buttonEnabled = classes [ pointer, dim, theme.bgButton, theme.fgButton ]
    , buttonDisabled = classes [ theme.bgButtonDisabled, theme.fgButtonDisabled ]
    , threadPreview = classes []
    , postForm = classes [ pa3 ]
    , previewPosts = classes [ pl5 ]
    , threadNo = classes [ theme.fgThreadNo ]
    , threadSubject = classes [ f4, theme.fgThreadSubject ]
    , threadSubjectBig = classes [ f2, mt2, mb3, fw5, theme.fgThreadSubject ]
    , postNo = classes [ theme.fgPostNo ]
    , op = classes [ pa1 ]
    , thread = classes []
    , post = classes [ mb3, pa2, br1, theme.bgPost ]
    , postHead = classes [ f6, overflow_hidden, pa1, theme.fgPostHead, theme.fontMono, theme.bgPost ]
    , postHeadElement = classes [ dib, mr2 ]
    , postName = classes [ dib, theme.fgPostName ]
    , postMediaPreviewContainer = classes [ fl, flex, flex_wrap ]
    , postMediaPreview = classes [ br1, fl, mr3, mt1 ]
    , opName = classes [ theme.fgOpName ]
    , postTrip = classes [ theme.fgPostTrip ]
    , postBody = classes [ pa1, overflow_hidden, pre, theme.fgPost, theme.bgPost ]
    , fgButton = classes [ theme.fgButton ]
    , textButton = classes [ b__solid, pa2, br1, outline_0, theme.bInput ]
    , iconicButton = classes iconicButton
    , menuButton = classes <| iconicButton ++ [ pa3 ]
    , flexFiller = classes [ flex_grow_1 ]
    , formContainer = classes [ h_100, w_100, flex, flex_row ]
    , formMetaPane = classes [ pl2, pr3, flex, flex_column ]
    , formBodyPane = classes [ pl3, flex_grow_1, flex, flex_column ]
    , formElement = classes [ db, mb3, w_100 ]
    , formButton = classes [ mt3, mb4 ]
    , formAreaAttachedFiles = classes [ flex, justify_center ]
    , formMediaPreview = classes [ h4, w4, mr2, relative, hide_child, pointer, overflow_hidden, br1, cover, bg_center ]
    , formMediaPreviewOverlay = classes [ absolute, h_100, w_100, pl3, pr3, flex, justify_center, flex_column, tc, child, bg_black_70 ]
    , formButtonAddImage = classes [ b__dashed, pa3, tc, br1, bw1, bg_transparent, theme.fgPost, theme.bInput ]
    , formProblems = classes [ h3 ]
    , textInput = classes [ pa1, br1, b__solid, theme.fgInput, theme.bgInput, theme.bInput ]
    , textArea = classes [ pa1, br1, b__solid, bw1, w_100, theme.fgInput, theme.bgInput, theme.bInput ]
    , hypertextLink = classes [ underline, theme.fgButton, dim ]
    , replyForm = classes [ mt4 ]
    }
