module Update.Index exposing (update)

import Commands
import List.Extra
import Model exposing (Model)
import Model.Media as Media
import Model.Page as Page
import Model.Post as Post
import Model.ThreadPreview as ThreadPreview
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( Msg.GotThreads result, Page.Index _ ) ->
            case result of
                Ok threads ->
                    ( { model | page = Page.Index << Page.Content <| List.reverse threads }, Cmd.none )

                Err error ->
                    Commands.showDefaultHttpErrorPopUp error model

        ( Msg.PostMediaClicked threadID postNo mediaID, Page.Index (Page.Content threads) ) ->
            let
                newThreads =
                    List.Extra.updateIf
                        (.id >> (==) threadID)
                        (ThreadPreview.mapLast postNo <| Post.mapMedia mediaID Media.togglePreview)
                        threads
            in
            ( { model | page = Page.Index (Page.Content newThreads) }, Cmd.none )

        _ ->
            ( model, Cmd.none )
