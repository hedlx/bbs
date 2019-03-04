module Route exposing (route)

import Dict
import Env
import Model.Page as Page exposing (Page)
import Regex
import Url exposing (Url)


route : Url -> Page
route { fragment } =
    case fragment of
        Nothing ->
            Page.Index

        Just "/" ->
            Page.index

        Just "" ->
            Page.index

        Just "/new" ->
            Page.newThread

        Just _ ->
            Page.notFound
