module Model.Post exposing (Post, decoder)

import Json.Decode as Decode


type alias Post =
    { no : Int
    , name : String
    , trip : String
    , text : String
    , ts : Int
    }


decoder =
    Decode.map5 Post
        (Decode.field "no" Decode.int)
        (optField "name" "Anonymous" Decode.string)
        (optField "trip" "" Decode.string)
        (Decode.field "text" Decode.string)
        (Decode.field "ts" Decode.int)


optField fieldId defaultValue decoderField =
    Decode.maybe (Decode.field fieldId decoderField)
        |> Decode.map (Maybe.withDefault defaultValue)
