module App.Model exposing (Route(..), Model, new)

import Pages.Filters.Model as Filters exposing (new, Model)
import Pages.Tweets.Model as Tweets exposing (new, Model)
import Filter.Model exposing (Filter)


type Route
    = TweetsRoute
    | FilterRoute Int
    | NotFoundRoute


type alias Model =
    { route : Route
    , filtersPage : Filters.Model
    , tweetsPage : Tweets.Model
    , filters : List Filter
    }


new : List Filter -> Model
new savedFilters =
    -- Active route
    { route =
        TweetsRoute
    -- Filters page model
    , filtersPage =
        Filters.new savedFilters
    -- Tweets page model
    , tweetsPage =
        Tweets.new savedFilters
    -- Saved filters
    , filters = savedFilters
    }
