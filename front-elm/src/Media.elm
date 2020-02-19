module Media exposing (ID, Media, decoder, togglePreview, url, urlPreview)

import Config exposing (Config)
import Json.Decode as Decode exposing (Decoder)
import Url.Builder


type alias Media =
    { id : ID
    , mime : String
    , orig_name : String
    , size : Int
    , width : Int
    , height : Int
    , isPreview : Bool
    }


type alias ID =
    String


togglePreview : Media -> Media
togglePreview media =
    { media | isPreview = not media.isPreview }


url : Config -> Media -> String
url { urlImage } media =
    let
        ext =
            case media.mime of
                "image/jpeg" ->
                    ".jpg"

                "image/png" ->
                    ".png"

                _ ->
                    ""
    in
    Url.Builder.crossOrigin urlImage [ media.id ++ ext ] []


urlPreview : Config -> Media -> String
urlPreview { urlThumb } media =
    Url.Builder.crossOrigin urlThumb [ media.id ] []


decoder : Decoder Media
decoder =
    Decode.map7 Media
        (Decode.field "id" Decode.string)
        (Decode.field "type_" Decode.string)
        (Decode.field "orig_name" Decode.string)
        (Decode.field "size" Decode.int)
        (Decode.field "width" Decode.int)
        (Decode.field "height" Decode.int)
        (Decode.succeed True)
