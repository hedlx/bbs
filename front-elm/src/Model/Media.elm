module Model.Media exposing (Media, decoder, togglePreview, url, urlPreview)

import Env
import Json.Decode as Decode
import Url.Builder


type alias Media =
    { id : String
    , mime : String
    , orig_name : String
    , size : Int
    , width : Int
    , height : Int
    , isPreview : Bool
    }


togglePreview media =
    { media | isPreview = not media.isPreview }


url media =
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
    Url.Builder.crossOrigin Env.urlImage [ media.id ++ ext ] []


urlPreview media =
    Url.Builder.crossOrigin Env.urlThumb [ media.id ] []


decoder =
    Decode.map7 Media
        (Decode.field "id" Decode.string)
        (Decode.field "type_" Decode.string)
        (Decode.field "orig_name" Decode.string)
        (Decode.field "size" Decode.int)
        (Decode.field "width" Decode.int)
        (Decode.field "height" Decode.int)
        (Decode.succeed True)
