module Model.Thread exposing (Thread, decoder, mapMessages)

import Json.Decode as Decode
import List.Extra
import Model.Post as Post exposing (Post)


type alias Thread =
    { id : Int
    , subject : Maybe String
    , messages : List Post
    }


mapMessages postNo f thread =
    { thread | messages = List.Extra.updateIf (.no >> (==) postNo) f thread.messages }


decoder threadID =
    Decode.map2 (Thread threadID)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "messages" <| Decode.list Post.decoder)
