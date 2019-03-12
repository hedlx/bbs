module Model.Thread exposing (Thread, decoder)

import Json.Decode as Decode
import Model.Post as Post exposing (Post)


type alias Thread =
    { id : Int
    , subject : Maybe String
    , messages : List Post
    }


decoder threadID =
    Decode.map2 (Thread threadID)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "messages" <| Decode.list Post.decoder)
