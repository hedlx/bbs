module Env exposing (bbsName, defaultName, fileFormats, serverUrl)


serverUrl : String
serverUrl =
    "https://bbs.hedlx.org:451/api"


fileFormats : List String
fileFormats =
    [ "image/png", "image/jpg", "image/jpeg", "image/tiff", "image/tif", "image/gif" ]


defaultName : String
defaultName =
    "Anonymous"


bbsName : String
bbsName =
    "Hedlx BBS"
