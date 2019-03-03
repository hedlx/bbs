module Commands exposing (getThreads)

import Env
import Http
import Model.Threads
import Msg
import Url.Builder


getThreads =
    Http.get
        { url = Url.Builder.crossOrigin Env.serverUrl [ "threads" ] []
        , expect = Http.expectJson Msg.GotThreads Model.Threads.decoder
        }
