module Model.Threads exposing (decoder)

import Json.Decode as Decode
import Model.Thread as Thread


decoder =
    Decode.list Thread.decoder
