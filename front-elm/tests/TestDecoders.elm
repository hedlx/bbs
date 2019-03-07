module TestDecoders exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Json.Decode as Decode
import Model.Post as Post
import Test exposing (..)


suite : Test
suite =
    describe "Json decoders"
        testPostDecoder


testPostDecoder =
    let
        expected =
            { no = 0
            , name = "Anonymous"
            , trip = ""
            , text = "Hi!"
            , ts = 1551523794
            }

        check fixture =
            let
                decoded =
                    Decode.decodeString Post.decoder fixture
            in
            Expect.all
                [ Expect.equal (Ok expected.no) << Result.map .no
                , Expect.equal (Ok expected.name) << Result.map .name
                , Expect.equal (Ok expected.trip) << Result.map .trip
                , Expect.equal (Ok expected.text) << Result.map .text
                , Expect.equal (Ok expected.ts) << Result.map .ts
                ]
                decoded
    in
    [ test "Post decoder on data with name and trip" <|
        \_ ->
            check """{"no":0,"name":"Anonymous","trip":"","text":"Hi!","ts":1551523794}"""
    , test "Post decoder on data with null name and null trip" <|
        \_ ->
            check """{"no":0,"name":null,"trip":null,"text":"Hi!","ts":1551523794}"""
    , test "Post decoder on data without name and trip" <|
        \_ ->
            check """{"no":0,"text":"Hi!","ts":1551523794}"""
    ]
