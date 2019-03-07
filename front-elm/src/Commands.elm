module Commands exposing (createPost, createThread, getThreads, init, redirect)

import Browser.Navigation as Nav
import Env
import Http
import Model.Page as Page
import Model.Post
import Model.Thread
import Model.Threads
import Msg
import Url
import Url.Builder


init page =
    case page of
        Page.Index (Page.Loading _) ->
            getThreads

        Page.Thread (Page.Loading tID) ->
            getThread tID

        _ ->
            Cmd.none


redirect pagePath model =
    Nav.pushUrl model.key (model.appPath ++ "#" ++ String.join "/" pagePath)


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
