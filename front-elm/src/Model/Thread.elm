module Model.Thread exposing (Thread, decoder)

import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Model.Post as Post exposing (Post)


type alias Thread =
    { id : Int
    , topic : String
    , op : Post
    , replies : List Post
    }


decoder =
    Decode.map4 Thread
        (Decode.field "id" Decode.int)
        (DecodeExt.withDefault "" <| Decode.field "topic" Decode.string)
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)
