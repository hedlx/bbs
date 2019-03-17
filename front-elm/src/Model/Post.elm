module Model.Post exposing (Post, decoder)

import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Model.Media as Media exposing (Media)


type alias Post =
    { no : Int
    , name : String
    , trip : String
    , text : String
    , ts : Int
    , media : List Media
    }


decoder =
    Decode.map6 Post
        (Decode.field "no" Decode.int)
        (DecodeExt.withDefault "Anonymous" <| Decode.field "name" Decode.string)
        (DecodeExt.withDefault "" <| Decode.field "trip" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "ts" Decode.int)
        (Decode.field "media" (Decode.list Media.decoder))
