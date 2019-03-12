module Model.Threads exposing (decoder)

import Json.Decode as Decode
import Model.ThreadPreview as ThreadPreview


decoder =
    Decode.list ThreadPreview.decoder
