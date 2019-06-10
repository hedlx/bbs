module Route.CrossPage exposing (CrossPage(..))

-- A 'cross page' route is a special kind of route
-- that allows to pass information between pages
-- without putting it into a query part of the URL.


type CrossPage
    = IndexLastThread Int
    | ReplyTo Int Int
