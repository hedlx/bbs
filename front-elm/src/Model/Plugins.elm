module Model.Plugins exposing (Plugins, init)

import Model.PopUp exposing (PopUp)
import Toasty


type alias Plugins =
    { toasties : Toasty.Stack PopUp }


init =
    { toasties = Toasty.initialState }
