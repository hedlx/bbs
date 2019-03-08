module Msg exposing (Msg(..))

import Browser
import Http
import Model.Limits exposing (Limits)
import Model.PostForm exposing (PostForm)
import Model.Thread exposing (Thread)
import Spinner
import Url exposing (Url)


type Msg
    = Empty
      -- Routes
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url
      -- HTTP Requests
    | GotLimits (Result Http.Error Limits)
    | GotThreads (Result Http.Error (List Thread))
    | GotThread (Result Http.Error Thread)
    | ThreadCreated (Result Http.Error ())
    | PostCreated Int (Result Http.Error ())
      -- Forms
    | FormNameChanged String
    | FormTripChanged String
    | FormPassChanged String
    | FormSubjChanged String
    | FormTextChanged String
    | FormSubmit
      -- Plugins
    | SpinnerMsg Spinner.Msg
