module PostForm.Attachments exposing
    ( Attachments
    , add
    , empty
    , encode
    , isEmpty
    , isExists
    , length
    , remove
    , toList
    , updateAttachment
    )

import Attachment exposing (Attachment, ID, Preview)
import File exposing (File)
import Json.Encode as Encode
import List.Extra


type Attachments
    = Attachments Table


type alias Table =
    { idCount : Int
    , attachments : List Attachment
    }


empty : Attachments
empty =
    Attachments
        { idCount = 0
        , attachments = []
        }


encode : Attachments -> Encode.Value
encode (Attachments table) =
    Encode.list identity (List.filterMap Attachment.encode table.attachments)


isEmpty : Attachments -> Bool
isEmpty (Attachments table) =
    List.isEmpty table.attachments


isExists : ID -> Attachments -> Bool
isExists id (Attachments table) =
    List.any (\attach -> attach.id == id) table.attachments


add : (ID -> Preview -> msg) -> List File -> Attachments -> ( Attachments, Cmd msg )
add toMsg newFiles (Attachments table) =
    let
        newCount =
            table.idCount + List.length newFiles

        newAttachments =
            List.indexedMap
                (\n ->
                    Attachment.fromFile (table.idCount + n)
                )
                newFiles

        cmdGeneratePreviews =
            Cmd.batch <|
                List.map (Attachment.generatePreview toMsg) newAttachments
    in
    ( Attachments
        { idCount = newCount
        , attachments = table.attachments ++ newAttachments
        }
    , cmdGeneratePreviews
    )


remove : ID -> Attachments -> Attachments
remove id (Attachments table) =
    Attachments { table | attachments = List.filter (\rec -> rec.id /= id) table.attachments }


updateAttachment : ID -> (Attachment -> Attachment) -> Attachments -> Attachments
updateAttachment id update (Attachments table) =
    Attachments { table | attachments = List.Extra.updateIf (.id >> (==) id) update table.attachments }


toList : Attachments -> List Attachment
toList (Attachments table) =
    table.attachments


length : Attachments -> Int
length (Attachments table) =
    List.length table.attachments
