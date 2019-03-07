module TestRoute exposing (suite)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Route
import Test exposing (..)
import Url


suite =
    describe "Routes"
        [ test "top-level " <|
            \_ ->
                Expect.equal "#" <|
                    Route.internalLink [ "/" ]
        , test "app path without /" <|
            \_ ->
                Expect.equal "#/resource" <|
                    Route.internalLink [ "resource" ]
        , test "app path with /" <|
            \_ ->
                Expect.equal "#/resource" <|
                    Route.internalLink [ "resource/" ]
        , test "paths with a lot of /" <|
            \_ ->
                Expect.equal "#/resource/1" <|
                    Route.internalLink [ "/resource/", "/1" ]
        ]
