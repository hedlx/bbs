module DomCmd exposing (scrollTo)

import Browser.Dom
import Ease
import SmoothScroll
import Task


scrollTo : (Result Browser.Dom.Error (List ()) -> msg) -> Int -> Int -> String -> Cmd msg
scrollTo toMsg offset speed domID =
    let
        cfgDefault =
            SmoothScroll.defaultConfig

        cfgScroll =
            { cfgDefault
                | offset = offset
                , speed = speed
                , easing = Ease.outQuint
            }
    in
    SmoothScroll.scrollToWithOptions cfgScroll domID
        |> Task.attempt toMsg
