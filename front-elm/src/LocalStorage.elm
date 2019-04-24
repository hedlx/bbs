port module LocalStorage exposing (saveUserSettings, userSettingsChanged)

import Json.Encode as Encode


port saveUserSettings : Encode.Value -> Cmd msg


port userSettingsChanged : (Encode.Value -> msg) -> Sub msg
