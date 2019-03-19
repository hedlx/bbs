module Model.ThreadPreview exposing (ThreadPreview, decoder, mapLast)

import Json.Decode as Decode
import List.Extra
import Model.Post as Post exposing (Post)


type alias ThreadPreview =
    { id : Int
    , subject : Maybe String
    , op : Post
    , last : List Post
    }


mapLast postNo f thread =
    { thread | last = List.Extra.updateIf (.no >> (==) postNo) f thread.last }


decoder =
    Decode.map4 ThreadPreview
        (Decode.field "id" Decode.int)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)
