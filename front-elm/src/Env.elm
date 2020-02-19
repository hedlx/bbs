module Env exposing
    ( bbsName
    , defaultApiPath
    , defaultImagePath
    , defaultName
    , defaultThumbPath
    , defaultUrlServer
    , fileFormats
    , lineLength
    , maxLineLength
    , maxPerPage
    , minLineLength
    , minPerPage
    , threadsPerPage
    )


defaultUrlServer : String
defaultUrlServer =
    "localhost:8000"


defaultApiPath : List String
defaultApiPath =
    [ "api" ]


defaultImagePath : List String
defaultImagePath =
    [ "i" ]


defaultThumbPath : List String
defaultThumbPath =
    [ "t" ]


fileFormats : List String
fileFormats =
    [ "image/png", "image/jpeg" ]


defaultName : String
defaultName =
    "Anonymous"


bbsName : String
bbsName =
    "hedλx BBS"


minPerPage : Int
minPerPage =
    1


maxPerPage : Int
maxPerPage =
    100


threadsPerPage : Int
threadsPerPage =
    8


minLineLength : Int
minLineLength =
    24


maxLineLength : Int
maxLineLength =
    256


lineLength : Int
lineLength =
    75
