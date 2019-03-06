module Model.ThreadForm exposing
    ( ThreadForm
    , countChars
    , countWords
    , empty
    , encode
    , isEmpty
    , isTextBlank
    , isValid
    , name
    , pass
    , setName
    , setPass
    , setText
    , text
    )

import Json.Encode as Encode
import Json.Decode as Decode


type ThreadForm
    = ThreadForm ThreadForm_


type alias ThreadForm_ =
    { name : String
    , text : String
    , pass : String
    }


encode (ThreadForm form) =
    let
        fixedName =
            if String.isEmpty (String.trim form.name) then
                "Anonymous"

            else
                String.trim form.name
    in
    Encode.object
        [ ( "name", Encode.string fixedName )
        , ( "secret", Encode.string form.pass )
        , ( "text", Encode.string form.text )
        ]


isEmpty (ThreadForm form) =
    String.isEmpty form.text
        && String.isEmpty form.pass


isTextBlank (ThreadForm form) =
    String.isEmpty (String.trim form.text)


isValid tform =
    not (isTextBlank tform)


empty =
    ThreadForm
        { name = ""
        , text = ""
        , pass = ""
        }


name (ThreadForm form) =
    form.name


text (ThreadForm form) =
    form.text


pass (ThreadForm form) =
    form.pass


setName newName (ThreadForm form) =
    ThreadForm { form | name = String.left 32 <| String.trimLeft newName }


setText newText (ThreadForm form) =
    ThreadForm { form | text = newText }


setPass newPass (ThreadForm form) =
    ThreadForm { form | pass = String.trim newPass }


countChars (ThreadForm form) =
    String.length <| form.text


countWords (ThreadForm form) =
    let
        words =
            String.words (String.trim form.text)
                |> List.filter isWord
    in
    List.length words

isWord str =
    not (String.isEmpty str)
