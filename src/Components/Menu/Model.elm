module Components.Menu.Model exposing (Model, MenuItem, new)

import Common exposing (Route(..))


type alias Model =
    { selectedIndex : Int
    , items : List MenuItem
    }


type alias MenuItem =
    { text : String
    , route : Route
    }


items : List MenuItem
items =
    [ MenuItem "Tweets" (TweetsRoute []), MenuItem "Filters" (FilterRoute 0) ]


new : Model
new =
    { selectedIndex = 0
    , items = items
    }
