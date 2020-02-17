module Env exposing
    ( bbsName
    , defaultName
    , defaultUrlServer
    , fileFormats
    , lineLength
    , maxLineLength
    , maxPerPage
    , minLineLength
    , minPerPage
    , threadsPerPage
    , urlAPI
    , urlImage
    , urlThumb
    )

import Url.Builder


defaultUrlServer : String
defaultUrlServer =
    "localhost:8000"


urlAPI : String -> String
urlAPI urlServer =
    Url.Builder.crossOrigin urlServer [ "api" ] []


urlImage : String -> String
urlImage urlServer =
    Url.Builder.crossOrigin urlServer [ "i" ] []


urlThumb : String -> String
urlThumb urlServer =
    Url.Builder.crossOrigin urlServer [ "t" ] []


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
