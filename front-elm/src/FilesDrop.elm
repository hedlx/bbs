module FilesDrop exposing (onDragOver, onDrop)

import File exposing (File)
import Html exposing (Attribute)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)


{-| If dragover is not handled the browser will replace the page with the dropped image.
-}
onDragOver : msg -> Attribute msg
onDragOver msg =
    preventDefaultOn "dragover" (Decode.succeed ( msg, True ))


onDrop : (List File -> msg) -> Attribute msg
onDrop toMsg =
    preventDefaultOn "drop" (decoderDropFiles toMsg)


decoderDropFiles : (List File -> msg) -> Decoder ( msg, Bool )
decoderDropFiles toMsgFilesDropped =
    Decode.field "dataTransfer" (Decode.field "files" (Decode.list File.decoder))
        |> Decode.map
            (\files -> ( toMsgFilesDropped files, True ))
