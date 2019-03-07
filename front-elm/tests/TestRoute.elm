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
                Expect.equal "#resource" <|
                    Route.link defaultUrl [ "resource" ]
        , test "app path without /" <|
            \_ ->
                Expect.equal "elm#resource" <|
                    Route.link { defaultUrl | path = "elm" } [ "resource" ]
        , test "app path with /" <|
            \_ ->
                Expect.equal "elm#resource" <|
                    Route.link { defaultUrl | path = "elm/" } [ "resource" ]
        , test "paths with a lot of /" <|
            \_ ->
                Expect.equal "elm#resource/1" <|
                    Route.link { defaultUrl | path = "elm//" } [ "resource/", "/1" ]
        ]


defaultUrl =
    { protocol = Url.Https
    , host = "hedlx.org"
    , port_ = Nothing
    , path = ""
    , query = Nothing
    , fragment = Nothing
    }
