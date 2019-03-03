module Commands exposing (getThreads, init)

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


getThreads =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , expect = Http.expectJson Msg.GotThreads Model.Threads.decoder
        }
