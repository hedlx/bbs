module Model.Post exposing (Post, decoder)

import Json.Decode as Decode


type alias Post =
    { no : Int
    , name : String
    , trip : String
    , text : String
    }


decoder =
    Decode.map4 Post
        (Decode.field "no" Decode.int)
        (Decode.field "name" Decode.string)
        (Decode.field "trip" Decode.string)
        (Decode.field "text" Decode.string)
