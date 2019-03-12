module Model.ThreadPreview exposing (ThreadPreview, decoder)

import Json.Decode as Decode
import Model.Post as Post exposing (Post)


type alias ThreadPreview =
    { id : Int
    , subject : Maybe String
    , op : Post
    , last : List Post
    }


decoder =
    Decode.map4 ThreadPreview
        (Decode.field "id" Decode.int)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)
