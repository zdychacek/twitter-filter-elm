module Pages.Tweets.Model exposing (Model, new)

import Exts.RemoteData exposing (RemoteData(..), WebData)
import Tweet.Model exposing (Tweet)
import Filter.Model exposing (Filter)


type alias Model =
    { tweets : WebData (List Tweet)
    , selectedFilters : List Filter
    , filters : List Filter
    }


new : List Filter -> Model
new savedFilters =
    { tweets = NotAsked
    , selectedFilters = []
    , filters = savedFilters
    }
