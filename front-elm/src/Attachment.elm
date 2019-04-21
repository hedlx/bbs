module Attachment exposing
    ( Attachment
    , Preview
    , encode
    , generatePreview
    , updateBackendID
    , updatePreview
    , upload
    )

import Env
import File exposing (File)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Task
import Url.Builder


type alias Attachment =
    { id : Int
    , file : File
    , preview : Maybe Preview
    , backendID : Maybe String
    }


type alias Preview =
    String


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


updateBackendID : String -> Attachment -> Attachment
updateBackendID backendID attachment =
    { attachment | backendID = Just backendID }


generatePreview : (Int -> Preview -> msg) -> Attachment -> Cmd msg
generatePreview toMsg { id, file } =
    Task.perform (toMsg id) (File.toUrl file)


upload : (Result Http.Error ( Int, String ) -> msg) -> Attachment -> Cmd msg
upload toMsg attachment =
    let
        path =
            [ "upload" ]

        addFileID =
            Result.map (\backendID -> ( attachment.id, backendID ))
    in
    Http.post
        { url = Url.Builder.crossOrigin Env.urlAPI path []
        , body = Http.multipartBody [ Http.filePart "media" attachment.file ]
        , expect = Http.expectJson (toMsg << addFileID) (Decode.field "id" Decode.string)
        }
