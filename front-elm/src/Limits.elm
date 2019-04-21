module Limits exposing (Limits, decoder, empty, hasUndefined)

import Json.Decode as Decode exposing (Decoder)


type alias Limits =
    { maxLenName : Maybe Int
    , maxLenSubj : Maybe Int
    , maxLenText : Maybe Int
    }


empty : Limits
empty =
    { maxLenName = Nothing
    , maxLenSubj = Nothing
    , maxLenText = Nothing
    }


hasUndefined : Limits -> Bool
hasUndefined limits =
    limits.maxLenName
        == Nothing
        || limits.maxLenSubj
        == Nothing
        || limits.maxLenText
        == Nothing


decoder : Decoder Limits
decoder =
    Decode.map3 Limits
        (Decode.field "msg_name_len" (Decode.maybe Decode.int))
        (Decode.field "msg_subject_len" (Decode.maybe Decode.int))
        (Decode.field "msg_text_len" (Decode.maybe Decode.int))
