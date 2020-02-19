module Attachment exposing
    ( Attachment
    , BackendID
    , ID
    , Preview
    , encode
    , fromFile
    , generatePreview
    , updateBackendID
    , updatePreview
    , upload
    )

import Config exposing (Config)
import File exposing (File)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task
import Url.Builder


type alias Attachment =
    { id : ID
    , file : File
    , preview : Maybe Preview
    , backendID : Maybe BackendID
    }


type alias ID =
    Int


type alias BackendID =
    String


type alias Preview =
    String


fromFile : ID -> File -> Attachment
fromFile id file =
    { id = id
    , file = file
    , preview = Nothing
    , backendID = Nothing
    }


encode : Attachment -> Maybe Encode.Value
encode attachment =
    attachment.backendID
        |> Maybe.map
            (\strBackendID ->
                Encode.object
                    [ ( "id", Encode.string strBackendID )
                    , ( "orig_name", Encode.string <| File.name attachment.file )
                    ]
            )


updatePreview : Preview -> Attachment -> Attachment
updatePreview preview attachment =
    { attachment | preview = Just preview }


updateBackendID : BackendID -> Attachment -> Attachment
updateBackendID backendID attachment =
    { attachment | backendID = Just backendID }


generatePreview : (ID -> Preview -> msg) -> Attachment -> Cmd msg
generatePreview toMsg { id, file } =
    Task.perform (toMsg id) (File.toUrl file)


upload : Config -> (Result Http.Error ( ID, BackendID ) -> msg) -> Attachment -> Cmd msg
upload { urlApi } toMsg attachment =
    let
        path =
            [ "upload" ]

        addFileID =
            Result.map (\backendID -> ( attachment.id, backendID ))
    in
    Http.post
        { url = Url.Builder.crossOrigin urlApi path []
        , body = Http.multipartBody [ Http.filePart "media" attachment.file ]
        , expect = Http.expectJson (toMsg << addFileID) (Decode.field "id" Decode.string)
        }
