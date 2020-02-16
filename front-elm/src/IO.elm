port module IO exposing (cleanUserSettings, saveUserSettings, userSettingsChanged)

import Json.Encode as Encode


port saveUserSettings : Encode.Value -> Cmd msg


port cleanUserSettings : () -> Cmd msg


port userSettingsChanged : (Encode.Value -> msg) -> Sub msg
