module Model.Media exposing (Media, decoder)

import Json.Decode as Decode


type alias Media =
    { id : String
    , mime : String
    , orig_name : String
    , size : Int
    , width : Int
    , height : Int
    }


decoder =
    Decode.map6 Media
        (Decode.field "id" Decode.string)
        (Decode.field "type_" Decode.string)
        (Decode.field "orig_name" Decode.string)
        (Decode.field "size" Decode.int)
        (Decode.field "width" Decode.int)
        (Decode.field "height" Decode.int)
