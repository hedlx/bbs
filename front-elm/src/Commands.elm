module Commands exposing (createPost, createThread, getThreads, init, redirect)

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


createThread jsonBody =
    Http.post
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , body = Http.jsonBody jsonBody
        , expect = Http.expectWhatever Msg.ThreadCreated
        }


createPost threadID jsonBody =
    Http.post
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads", String.fromInt threadID ] []
        , body = Http.jsonBody jsonBody
        , expect = Http.expectWhatever (Msg.PostCreated threadID)
        }
