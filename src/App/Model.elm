module App.Model exposing (Model, new, Route(..))

import Filter.Model exposing (Filter)
import Pages.Filters.Model as Filters exposing (new, Model)
import Pages.Tweets.Model as Tweets exposing (new, Model)


type alias Model =
    { route : Route
    , filtersPage : Filters.Model
    , tweetsPage : Tweets.Model
    , filters : List Filter
    }


type Route
    = TweetsRoute (List Int)
    | FilterRoute Int
    | NotFoundRoute


new : List Filter -> Model
new savedFilters =
    -- Active route
    { route =
        TweetsRoute []
    -- Filters page model
    , filtersPage =
        Filters.new savedFilters
    -- Tweets page model
    , tweetsPage =
        Tweets.new savedFilters
    -- Saved filters
    , filters = savedFilters
    }
