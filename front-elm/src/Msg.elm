module Msg exposing (Msg(..))

import Browser
import Http
import Model.Thread exposing (Thread)
import Spinner
import Url exposing (Url)


type Msg
    = Empty
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
    | GotThreads (Result Http.Error (List Thread))
    | SpinnerMsg Spinner.Msg
