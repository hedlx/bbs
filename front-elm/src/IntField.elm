module IntField exposing
    ( IntField
    , Limits
    , decoder
    , edit
    , encode
    , fromInt
    , fromLimits
    , fromString
    , input
    , isChanged
    , range
    , submit
    , toInt
    , toString
    , update
    , updateString
    )

import Html exposing (..)
import Html.Attributes as Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Extra as DecodeExt
import Json.Encode as Encode
import Keyboard
import Keyboard.Events as KeyboardEv
import Regex exposing (Regex)


type IntField
    = IntField Limits Int
    | IntFieldEdit Limits Int String


type alias Limits =
    ( Int, Int, Int )


fromLimits : Limits -> IntField
fromLimits (( _, default, _ ) as lim) =
    IntField lim default


limits : IntField -> Limits
limits intField =
    case intField of
        IntField lim _ ->
            lim

        IntFieldEdit lim _ _ ->
            lim


trim : Limits -> Int -> Int
trim ( minInt, _, maxInt ) n =
    if n < minInt then
        minInt

    else if maxInt < n then
        maxInt

    else
        n


toInt : IntField -> Int
toInt intField =
    case intField of
        IntField _ n ->
            n

        IntFieldEdit _ n _ ->
            n


toString : IntField -> String
toString perPage =
    case perPage of
        IntField _ n ->
            String.fromInt n

        IntFieldEdit _ _ str ->
            str


fromInt : Limits -> Int -> IntField
fromInt lim n =
    IntField lim (trim lim n)


fromString : Limits -> String -> IntField
fromString lim str =
    Decode.decodeString (decoder lim) str
        |> Result.withDefault (fromLimits lim)


decoder : Limits -> Decoder IntField
decoder lim =
    Decode.map (fromInt lim) Decode.int
        |> DecodeExt.withDefault (fromLimits lim)


encode : IntField -> Encode.Value
encode intField =
    case intField of
        IntField _ n ->
            Encode.int n

        _ ->
            Encode.null


isChanged : IntField -> Bool
isChanged intField =
    case intField of
        IntFieldEdit _ n str ->
            String.toInt str /= Just n

        _ ->
            False


submit : IntField -> IntField
submit intFieldField =
    case intFieldField of
        IntFieldEdit lim _ str ->
            fromString lim str

        _ ->
            intFieldField


edit : IntField -> IntField
edit intField =
    case intField of
        IntField lim n ->
            IntFieldEdit lim n (String.fromInt n)

        _ ->
            intField


update : Int -> IntField -> IntField
update n intField =
    case intField of
        IntField lim _ ->
            IntField lim (trim lim n)

        IntFieldEdit lim _ str ->
            IntFieldEdit lim (trim lim n) str


updateString : String -> IntField -> IntField
updateString str intField =
    if Regex.contains regexIntFieldEdit str then
        case intField of
            IntFieldEdit lim n _ ->
                IntFieldEdit lim n str

            _ ->
                intField

    else
        intField


regexIntFieldEdit : Regex
regexIntFieldEdit =
    Regex.fromString "^\\d*$"
        |> Maybe.withDefault Regex.never



-- View


type alias InputEventHandlers msg =
    { onEdit : msg
    , onChange : String -> msg
    , onSubmit : msg
    }


input : InputEventHandlers msg -> List (Attribute msg) -> IntField -> Html msg
input ev attrs intField =
    let
        ( minInt, default, maxInt ) =
            limits intField
    in
    Html.input
        (type_ "number"
            :: Attributes.min (String.fromInt minInt)
            :: Attributes.max (String.fromInt maxInt)
            :: value (toString intField)
            :: placeholder (String.fromInt default)
            :: onFocus ev.onEdit
            :: onBlur (\_ -> ev.onSubmit)
            :: onInput ev.onChange
            :: KeyboardEv.on KeyboardEv.Keydown
                [ ( Keyboard.Escape, ev.onSubmit )
                , ( Keyboard.Enter, ev.onSubmit )
                ]
            :: attrs
        )
        []


onBlur : (String -> msg) -> Attribute msg
onBlur tagger =
    on "blur" (Decode.map tagger targetValue)


type alias RangeEventHandlers msg =
    { onChange : Int -> msg }


range : RangeEventHandlers msg -> List (Attribute msg) -> IntField -> Html msg
range ev attrs intField =
    let
        ( minInt, default, maxInt ) =
            limits intField
    in
    Html.input
        (type_ "range"
            :: Attributes.min (String.fromInt minInt)
            :: Attributes.max (String.fromInt maxInt)
            :: value (toString intField)
            :: onInput (\str -> ev.onChange (Maybe.withDefault default (String.toInt str)))
            :: attrs
        )
        []
