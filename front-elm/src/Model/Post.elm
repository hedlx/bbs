module Model.Post exposing (Post, decoder, mapMedia)

import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Model.Media as Media exposing (Media)
import List.Extra

type alias Post =
    { no : Int
    , name : String
    , trip : String
    , text : String
    , ts : Int
    , media : List Media
    }


mapMedia mediaID f post =
    { post | media = List.Extra.updateIf (.id >> (==) mediaID) f post.media }


decoder =
    Decode.map6 Post
        (Decode.field "no" Decode.int)
        (DecodeExt.withDefault "Anonymous" <| Decode.field "name" Decode.string)
        (DecodeExt.withDefault "" <| Decode.field "trip" Decode.string)
        (Decode.field "text" (Decode.oneOf [ Decode.string, Decode.null "" ]))
        (Decode.field "ts" Decode.int)
        (Decode.field "media" (Decode.list Media.decoder))
