module PostForm.Attachments exposing
    ( Attachments
    , add
    , empty
    , encode
    , isEmpty
    , isExists
    , map
    , remove
    , toList
    )

import Attachment exposing (Attachment)
import Json.Encode as Encode
import List.Extra


type Attachments
    = Attachments Table


type alias Table =
    { idCount : Int
    , attachments : List Attachment
    }


empty =
    Attachments
        { idCount = 0
        , attachments = []
        }


encode (Attachments table) =
    Encode.list identity (List.filterMap Attachment.encode table.attachments)


toList (Attachments table) =
    table.attachments


isEmpty (Attachments table) =
    List.isEmpty table.attachments


map id update (Attachments table) =
    Attachments { table | attachments = List.Extra.updateIf (.id >> (==) id) update table.attachments }


add toMsg newAttachments (Attachments table) =
    let
        newCount =
            table.idCount + List.length newAttachments

        createdAttachments =
            List.indexedMap
                (\n file ->
                    { id = table.idCount + n
                    , file = file
                    , preview = Nothing
                    , backendID = Nothing
                    }
                )
                newAttachments

        cmdGeneratePreviews =
            Cmd.batch <|
                List.map (Attachment.generatePreview toMsg) createdAttachments
    in
    ( Attachments
        { idCount = newCount
        , attachments = table.attachments ++ createdAttachments
        }
    , cmdGeneratePreviews
    )


remove id (Attachments table) =
    Attachments { table | attachments = List.filter (\rec -> rec.id /= id) table.attachments }


isExists id (Attachments table) =
    List.any (\rec -> rec.id == id) table.attachments
