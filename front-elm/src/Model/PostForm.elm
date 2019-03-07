module Model.PostForm exposing
    ( PostForm
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
    , setTrip
    , text
    , trip
    )

import Env
import Json.Decode as Decode
import Json.Encode as Encode


type PostForm
    = PostForm PostForm_


type alias PostForm_ =
    { name : String
    , trip : String
    , pass : String
    , text : String
    }


encode (PostForm form) =
    let
        fixedName =
            if String.isEmpty (String.trim form.name) then
                "Anonymous"

            else
                String.trim form.name
    in
    Encode.object
        [ ( "name", Encode.string fixedName )
        , ( "secret", Encode.string form.trip )
        , ( "password", Encode.string form.pass )
        , ( "text", Encode.string form.text )
        ]


isEmpty (PostForm form) =
    String.isEmpty form.text
        && String.isEmpty form.pass


isTextBlank (PostForm form) =
    String.isEmpty (String.trim form.text)


isValid postForm =
    not (isTextBlank postForm)


empty =
    PostForm
        { name = ""
        , trip = ""
        , pass = ""
        , text = ""
        }


name (PostForm form) =
    form.name


text (PostForm form) =
    form.text


trip (PostForm form) =
    form.trip


pass (PostForm form) =
    form.pass


setName newName (PostForm form) =
    PostForm { form | name = String.left Env.maxNameLength <| String.trimLeft newName }


setText newText (PostForm form) =
    PostForm { form | text = String.left Env.maxPostLength <| newText }


setTrip newTrip (PostForm form) =
    PostForm { form | trip = String.trim newTrip }


setPass newPass (PostForm form) =
    PostForm { form | pass = String.trim newPass }


countChars (PostForm form) =
    String.length <| form.text


countWords (PostForm form) =
    let
        words =
            String.words (String.trim form.text)
                |> List.filter isWord
    in
    List.length words


isWord str =
    not (String.isEmpty str)
