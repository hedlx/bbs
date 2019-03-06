module Msg exposing (Msg(..))

import Browser
import Http
import Model.Thread exposing (Thread)
import Spinner
import Url exposing (Url)


type Msg
    = Empty
      -- Routes
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
      -- HTTP Requests
    | GotThreads (Result Http.Error (List Thread))
    | GotThread (Result Http.Error Thread)
    | ThreadCreated (Result Http.Error ())
      -- Forms
    | FormNameChanged String
    | FormPassChanged String
    | FormTextChanged String
    | FormSubmit
      -- Plugins
    | SpinnerMsg Spinner.Msg
