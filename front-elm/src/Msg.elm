module Msg exposing (Msg(..))

import Http
import Model.Thread exposing (Thread)
import Spinner


type Msg
    = Empty
    | GotThreads (Result Http.Error (List Thread))
    | SpinnerMsg Spinner.Msg
