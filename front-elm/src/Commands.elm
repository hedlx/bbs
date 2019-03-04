module Commands exposing (createThread, getThreads, init, redirect)

import Browser.Navigation as Nav
import Env
import Http
import Model.Page as Page
import Model.Threads
import Msg
import Url
import Url.Builder


init page =
    case page of
        Page.Index ->
            getThreads

        _ ->
            Cmd.none


redirect pagePath model =
    Nav.pushUrl model.key (model.appPath ++ "#" ++ pagePath)


getThreads =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , expect = Http.expectJson Msg.GotThreads Model.Threads.decoder
        }


createThread jsonBody =
    Http.post
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , body = Http.jsonBody jsonBody
        , expect = Http.expectWhatever Msg.ThreadCreated
        }
