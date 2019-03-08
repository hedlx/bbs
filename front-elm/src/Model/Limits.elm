module Model.Limits exposing (Limits, decoder)

import Json.Decode as Decode


type alias Limits =
    { maxLenName : Int
    , maxLenSubj : Int
    , maxLenText : Int
    }


decoder =
    Decode.map3 Limits
        (Decode.field "msg_name_len" Decode.int)
        (Decode.field "msg_subject_len" Decode.int)
        (Decode.field "msg_text_len" Decode.int)
