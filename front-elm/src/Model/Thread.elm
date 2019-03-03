module Model.Thread exposing (Thread, decoder)

import Json.Decode as Decode
import Model.Post as Post exposing (Post)


type alias Thread =
    { id : Int
    , op : Post
    , replies : List Post
    }


decoder =
    Decode.map3 Thread
        (Decode.field "id" Decode.int)
        (Decode.field "op" Post.decoder)
        (Decode.field "last" (Decode.list Post.decoder))
