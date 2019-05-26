module Limits exposing (Limits, decoder, empty, hasUndefined)

import Json.Decode as Decode exposing (Decoder)


type alias Limits =
    { maxLenName : Maybe Int
    , maxLenSubj : Maybe Int
    , maxLenText : Maybe Int
    , maxCountMedia : Maybe Int
    , maxLenMediaName : Maybe Int
    , maxSizeMediaFile : Maybe Int
    }


empty : Limits
empty =
    Limits
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing
        Nothing


hasUndefined : Limits -> Bool
hasUndefined limits =
    limits.maxLenName
        == Nothing
        || limits.maxLenSubj
        == Nothing
        || limits.maxLenText
        == Nothing
        || limits.maxCountMedia
        == Nothing
        || limits.maxLenMediaName
        == Nothing
        || limits.maxSizeMediaFile
        == Nothing


decoder : Decoder Limits
decoder =
    Decode.map6 Limits
        (decoderLimit "msg_name_len")
        (decoderLimit "msg_subject_len")
        (decoderLimit "msg_text_len")
        (decoderLimit "media_max_count")
        (decoderLimit "media_orig_name_len")
        (decoderLimit "media_max_file_size")


decoderLimit : String -> Decoder (Maybe Int)
decoderLimit limitID =
    Decode.field limitID (Decode.maybe Decode.int)
