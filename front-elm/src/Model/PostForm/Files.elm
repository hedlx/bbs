module Model.PostForm.Files exposing
    ( Files
    , add
    , empty
    , encode
    , isEmpty
    , isExists
    , remove
    , toList
    , updateFileBackendID
    , updatePreview
    )

import File exposing (File)
import Json.Encode as Encode
import List.Extra
import Task


type Files
    = Files Files_


type alias Files_ =
    { idCount : Int
    , records : List Record
    }


type alias Record =
    { id : Int
    , file : File
    , preview : Maybe String
    , backendID : Maybe String
    }


empty =
    Files
        { idCount = 0
        , records = []
        }


encode (Files db) =
    Encode.list identity (List.filterMap encodeRecord db.records)


encodeRecord rec =
    rec.backendID
        |> Maybe.map
            (\strBackendID ->
                Encode.object
                    [ ( "id", Encode.string strBackendID )
                    , ( "orig_name", Encode.string <| File.name rec.file )
                    ]
            )


toList (Files db) =
    db.records


isEmpty (Files db) =
    List.isEmpty db.records


add newFiles (Files db) =
    let
        newCount =
            db.idCount + List.length newFiles

        createdRecords =
            List.indexedMap
                (\n file ->
                    { id = db.idCount + n
                    , file = file
                    , preview = Nothing
                    , backendID = Nothing
                    }
                )
                newFiles
    in
    ( Files
        { idCount = newCount
        , records = db.records ++ createdRecords
        }
    , generateFilesPreviews createdRecords
    )


isExists id (Files db) =
    List.any (\rec -> rec.id == id) db.records


remove id (Files db) =
    Files { db | records = List.filter (\rec -> rec.id /= id) db.records }


updatePreview id preview =
    map id (\rec -> { rec | preview = Just preview })


updateFileBackendID id backendID =
    map id (\rec -> { rec | backendID = Just backendID })


map id update (Files db) =
    Files { db | records = List.Extra.updateIf (.id >> (==) id) update db.records }


generateFilesPreviews records toMsg =
    records
        |> List.map (\{ id, file } -> Task.perform (toMsg id) (File.toUrl file))
        >> Cmd.batch
