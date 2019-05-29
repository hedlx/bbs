-- Redirect is used for cross-page integrations.
-- It allows data to be passed between pages.


module Page.Redirect exposing (Redirect(..))


type Redirect
    = Path (List String)
    | ReplyTo Int Int
