module Model.PostForm exposing
    ( PostForm
    , countChars
    , countWords
    , empty
    , encode
    , hasSubj
    , isEmpty
    , isTextBlank
    , isValid
    , limits
    , name
    , pass
    , setName
    , setPass
    , setSubj
    , setText
    , setTrip
    , subj
    , text
    , trip
    )

import Env
import Json.Decode as Decode
import Json.Encode as Encode


type PostForm
    = PostForm PostForm_


type alias PostForm_ =
    { limits : Maybe Limits
    , name : String
    , trip : String
    , pass : String
    , subj : Maybe String
    , text : String
    }


type alias Limits =
    { maxLenName : Int
    , maxLensubj : Int
    , maxLentext : Int
    }


encode (PostForm form) =
    let
        fixedName =
            if String.isEmpty (String.trim form.name) then
                "Anonymous"

            else
                String.trim form.name

        formSubjOrEmpty =
            form.subj
                |> Maybe.map (\subjVal -> [ ( "subject", Encode.string subjVal ) ])
                >> Maybe.withDefault []
    in
    Encode.object <|
        [ ( "name", Encode.string fixedName )
        , ( "secret", Encode.string form.trip )
        , ( "password", Encode.string form.pass )
        , ( "text", Encode.string form.text )
        ]
            ++ formSubjOrEmpty


isEmpty (PostForm form) =
    String.isEmpty form.text
        && String.isEmpty form.pass


isTextBlank (PostForm form) =
    String.isEmpty (String.trim form.text)


isValid postForm =
    not (isTextBlank postForm)


hasSubj (PostForm form) =
    form.subj /= Nothing


empty =
    PostForm
        { limits = Nothing
        , name = ""
        , trip = ""
        , pass = ""
        , subj = Nothing
        , text = ""
        }


limits (PostForm form) =
    form.limits


name (PostForm form) =
    form.name


trip (PostForm form) =
    form.trip


pass (PostForm form) =
    form.pass


subj (PostForm form) =
    form.subj


text (PostForm form) =
    form.text


setName newName (PostForm form) =
    PostForm { form | name = String.left Env.maxNameLength <| String.trimLeft newName }


setTrip newTrip (PostForm form) =
    PostForm { form | trip = String.trim newTrip }


setPass newPass (PostForm form) =
    PostForm { form | pass = String.trim newPass }


setSubj newSubj (PostForm form) =
    PostForm { form | subj = Just newSubj }


setText newText (PostForm form) =
    PostForm { form | text = String.left Env.maxPostLength <| newText }


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
