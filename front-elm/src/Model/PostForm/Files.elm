module Model.PostForm.Files exposing
    ( Files
    , add
    , empty
    , isExists
    , remove
    , toList
    , updatePreview
    )

import File exposing (File)
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
    , preview : String
    }


empty =
    Files
        { idCount = 0
        , records = []
        }


toList (Files db) =
    db.records


add newFiles (Files db) =
    let
        newCount =
            db.idCount + List.length newFiles

        createdRecords =
            List.indexedMap
                (\n file ->
                    { id = db.idCount + n
                    , file = file
                    , preview = ""
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
    map id (\rec -> { rec | preview = preview })


map id update (Files db) =
    let
        updateTargetOnly rec =
            if rec.id == id then
                update rec

            else
                rec
    in
    Files { db | records = List.map updateTargetOnly db.records }


generateFilesPreviews records toMsg =
    records
        |> List.map (\{ id, file } -> Task.perform (toMsg id) (File.toUrl file))
        >> Cmd.batch
