module Model.Limits exposing (Limits, decoder, empty, hasUndefined)

import Json.Decode as Decode


type alias Limits =
    { maxLenName : Maybe Int
    , maxLenSubj : Maybe Int
    , maxLenText : Maybe Int
    }


empty =
    { maxLenName = Nothing
    , maxLenSubj = Nothing
    , maxLenText = Nothing
    }


hasUndefined limits =
    limits.maxLenName
        == Nothing
        || limits.maxLenSubj
        == Nothing
        || limits.maxLenText
        == Nothing


decoder =
    Decode.map3 Limits
        (Decode.field "msg_name_len" (Decode.maybe Decode.int))
        (Decode.field "msg_subject_len" (Decode.maybe Decode.int))
        (Decode.field "msg_text_len" (Decode.maybe Decode.int))
