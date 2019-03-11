module Update.PostProcess exposing (update)

import Commands
import Model.Page as Page
import Model.PostForm as PostForm
import Msg


update msg model =
    case ( msg, model.page ) of
        ( Msg.ReplyTo threadID postID, Page.Thread state form ) ->
            let
                newPostForm =
                    appendReplyRef postID form
            in
            ( { model | page = Page.Thread state newPostForm }, Commands.focus "post-form-text" )

        ( Msg.ReplyTo threadID postID, Page.Index _ ) ->
            let
                newPostForm =
                    appendReplyRef postID (PostForm.init model.cfg.limits)

                newModel =
                    { model | page = Page.Thread (Page.Loading threadID) newPostForm }
            in
            ( newModel, Commands.redirect [ "threads", String.fromInt threadID ] newModel )

        ( Msg.GotThread _, Page.Thread state postForm ) ->
            if String.isEmpty (PostForm.text postForm) then
                ( model, Commands.scrollPageToTop )

            else
                ( model, Commands.focus "post-form-text" )

        ( Msg.GotThreads _, Page.Index _ ) ->
            ( model, Commands.scrollPageToTop )

        _ ->
            ( model, Cmd.none )


appendReplyRef postID form =
    PostForm.setText (PostForm.text form ++ ">>" ++ String.fromInt postID ++ "\n") form
