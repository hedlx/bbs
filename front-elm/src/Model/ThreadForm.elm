module Model.ThreadForm exposing
    ( ThreadForm
    , empty
    , encode
    , isEmpty
    , isValid
    , name
    , pass
    , setName
    , setPass
    , setText
    , text
    )

import Json.Encode as Encode


type ThreadForm
    = ThreadForm ThreadForm_


type alias ThreadForm_ =
    { name : String
    , text : String
    , pass : String
    }


encode (ThreadForm form) =
    Encode.object
        [ ( "name", Encode.string form.name )
        , ( "secret", Encode.string form.pass )
        , ( "text", Encode.string form.text )
        ]


isEmpty (ThreadForm form) =
    String.isEmpty form.name
        && String.isEmpty form.text
        && String.isEmpty form.pass


isValid (ThreadForm form) =
    not (String.isEmpty (String.trim form.name))
        && not (String.isEmpty (String.trim form.text))


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
    ThreadForm { form | name = String.trim newName }


setText newText (ThreadForm form) =
    ThreadForm { form | text = newText }


setPass newPass (ThreadForm form) =
    ThreadForm { form | pass = String.trim newPass }
