module Subscriptions.Plugins exposing (subscriptions)

import Model exposing (Model)
import Model.Page
import Msg exposing (Msg)
import Spinner


subscriptions model =
    let
        subSpinner =
            if Model.Page.isLoading model.page then
                Sub.map Msg.SpinnerMsg Spinner.subscription

            else
                Sub.none
    in
    Sub.batch [ subSpinner ]
