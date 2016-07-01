module Pages.Filters.Model exposing (Model, new)

import Filter.Model exposing (Filter)


type alias Model =
    { filters : List Filter
    , selectedFilter : Maybe Filter
    , name : String
    , tags : List String
    }


new : List Filter -> Model
new savedFilters =
    { filters = savedFilters
    , selectedFilter = Nothing
    , name = ""
    , tags = []
    }
