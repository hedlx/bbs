module Update.PostProcess exposing (update)

import Commands
import Model exposing (Model)
import Model.Page as Page
import Model.PostForm as PostForm
import Msg exposing (Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( Msg.ReplyTo _ postID, Page.Thread state form ) ->
            let
                newPostForm =
                    appendReplyRef postID form
            in
            ( { model | page = Page.Thread state newPostForm }, Commands.focus "post-form-text" )

        ( Msg.ReplyTo threadID postID, Page.Index _ ) ->
            let
                initForm =
                    PostForm.autofocus (PostForm.init model.cfg.limits)

                newPostForm =
                    if postID > 0 then
                        appendReplyRef postID initForm

                    else
                        initForm

                newModel =
                    { model | page = Page.Thread (Page.Loading threadID) newPostForm }
            in
            ( newModel, Commands.redirect [ "threads", String.fromInt threadID ] newModel )

        ( Msg.GotThread _, Page.Thread _ postForm ) ->
            if PostForm.isAutofocus postForm then
                ( model, Commands.focus "post-form-text" )

            else
                ( model, Commands.scrollPageToTop )

        ( Msg.GotThreads _, Page.Index _ ) ->
            ( model, Commands.scrollPageToTop )

        ( Msg.Unfocus id, _ ) ->
            ( model, Cmd.batch [ Commands.blur id ] )

        _ ->
            ( model, Cmd.none )


appendReplyRef postID form =
    PostForm.setText (PostForm.text form ++ ">>" ++ String.fromInt postID ++ "\n") form
