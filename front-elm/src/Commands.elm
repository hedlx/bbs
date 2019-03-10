module Commands exposing (createPost, createThread, getThreads, init, redirect, scrollPageToTop)

import Browser.Dom as Dom
import Browser.Navigation as Nav
import Env
import Http
import Model.Limits
import Model.Page as Page
import Model.Post
import Model.Thread
import Model.Threads
import Msg
import Route
import Task
import Url
import Url.Builder


init model =
    let
        pageSpecific =
            case model.page of
                Page.Index (Page.Loading _) ->
                    getThreads

                Page.Thread (Page.Loading tID) ->
                    getThread tID

                _ ->
                    Cmd.none

        limitsInit =
            if Model.Limits.hasUndefined model.cfg.limits then
                getLimits

            else
                Cmd.none
    in
    Cmd.batch [ limitsInit, pageSpecific ]


redirect pagePath model =
    Nav.pushUrl model.cfg.key <| Route.internalLink pagePath


scrollPageToTop =
    Dom.setViewportOf "page-content" 0.0 0.0
        |> Task.attempt (\_ -> Msg.Empty)


getLimits =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "limits" ] []
        , expect = Http.expectJson Msg.GotLimits Model.Limits.decoder
        }


getThreads =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , expect = Http.expectJson Msg.GotThreads Model.Threads.decoder
        }


getThread threadID =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads", String.fromInt threadID ] []
        , expect = Http.expectJson Msg.GotThread (Model.Thread.decoderPostList threadID)
        }


createThread hasAttachments formPostBody =
    let
        -- TODO: Make main path to accept multipart
        path =
            if hasAttachments then
                [ "threads", "multipart" ]

            else
                [ "threads" ]
    in
    Http.post
        { url = Url.Builder.crossOrigin Env.serverUrl path []
        , body = formPostBody
        , expect = Http.expectWhatever Msg.ThreadCreated
        }


createPost threadID hasAttachments formPostBody =
    let
        -- TODO: Make main path to accept multipart
        path =
            if hasAttachments then
                [ "threads", "multipart", String.fromInt threadID ]

            else
                [ "threads", String.fromInt threadID ]
    in
    Http.post
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads", String.fromInt threadID ] []
        , body = formPostBody
        , expect = Http.expectWhatever (Msg.PostCreated threadID)
        }
