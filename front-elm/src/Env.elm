module Env exposing (bbsName, defaultName, fileFormats, urlAPI, urlServer, urlThumb)

import Url.Builder


urlServer : String
urlServer =
    "https://bbs.hedlx.org:451"


urlAPI : String
urlAPI =
    Url.Builder.crossOrigin urlServer [ "api" ] []


urlThumb : String
urlThumb =
    Url.Builder.crossOrigin urlServer [ "t" ] []


fileFormats : List String
fileFormats =
    [ "image/png", "image/jpg", "image/jpeg", "image/tiff", "image/tif", "image/gif" ]


defaultName : String
defaultName =
    "Anonymous"


bbsName : String
bbsName =
    "Hedlx BBS"
