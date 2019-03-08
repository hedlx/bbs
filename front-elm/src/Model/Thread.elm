module Model.Thread exposing (Thread, decoder, decoderPostList, fromPostList)

import Json.Decode as Decode
import Json.Decode.Extra as DecodeExt
import Model.Post as Post exposing (Post)


type alias Thread =
    { id : Int
    , subject : Maybe String
    , op : Post
    , replies : List Post
    }


decoder =
    Decode.map4 Thread
        (Decode.field "id" Decode.int)
        (Decode.field "subject" (Decode.maybe Decode.string))
        (Decode.field "op" Post.decoder)
        (Decode.field "last" <| Decode.list Post.decoder)


decoderPostList : Int -> Decode.Decoder Thread
decoderPostList threadID =
    Decode.list Post.decoder
        |> Decode.andThen
            (fromPostList threadID
                >> Maybe.map Decode.succeed
                >> Maybe.withDefault (Decode.fail "Can't build thread from list")
            )


fromPostList : Int -> List Post -> Maybe Thread
fromPostList threadID lsPost =
    let
        maybeOp =
            List.head lsPost

        replies =
            List.tail lsPost |> Maybe.withDefault []
    in
    maybeOp
        |> Maybe.map
            (\op ->
                { id = threadID
                , subject = Nothing
                , op = op
                , replies = replies
                }
            )
