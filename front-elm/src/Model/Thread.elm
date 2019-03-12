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



-- decoderPostList : Int -> Decode.Decoder Thread
-- decoderPostList threadID =
--     Decode.list Post.decoder
--         |> Decode.andThen
--             (fromPostList threadID
--                 >> Maybe.map Decode.succeed
--                 >> Maybe.withDefault (Decode.fail "Can't build thread from list")
--             )
-- fromPostList : Int -> List Post -> Maybe Thread
-- fromPostList threadID lsPost =
--     let
--         maybeOp =
--             List.head lsPost
--         replies =
--             List.tail lsPost |> Maybe.withDefault []
--     in
--     maybeOp
--         |> Maybe.map
--             (\op ->
--                 { id = threadID
--                 , subject = Nothing
--                 , op = op
--                 , replies = replies
--                 }
--             )
