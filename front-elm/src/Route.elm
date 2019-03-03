module Route exposing (route)

import Model.Page as Page exposing (Page)
import Url exposing (Url)


route : Url -> Page
route url =
    case url.path of
        "/" ->
            Page.Index

        "/new" ->
            Page.NewThread

        _ ->
            Page.NotFound
