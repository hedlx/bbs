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
    , setLimits
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
import Model.Limits as Limits exposing (Limits)


type PostForm
    = PostForm PostForm_


type alias PostForm_ =
    { limits : Limits
    , name : String
    , trip : String
    , pass : String
    , subj : Maybe String
    , text : String
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
        { limits = Limits.empty
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
    PostForm { form | name = limitString form.limits.maxLenName <| String.trimLeft newName }


setTrip newTrip (PostForm form) =
    PostForm { form | trip = String.trim newTrip }


setPass newPass (PostForm form) =
    PostForm { form | pass = String.trim newPass }


setSubj newSubj (PostForm form) =
    PostForm { form | subj = Just (limitString form.limits.maxLenSubj <| String.trimLeft newSubj) }


setText newText (PostForm form) =
    PostForm { form | text = limitString form.limits.maxLenText newText }


setLimits newLimits (PostForm form) =
    PostForm
        { form
            | limits = newLimits
            , name = limitString newLimits.maxLenName form.name
            , subj = Maybe.map (limitString newLimits.maxLenSubj) form.subj
            , text = limitString newLimits.maxLenText form.text
        }


limitString maybeLimit str =
    maybeLimit
        |> Maybe.map (\maxLen -> String.left maxLen str)
        >> Maybe.withDefault str


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
