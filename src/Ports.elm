port module Ports exposing (..)

import Filter.Model exposing (Filter)


port saveFilters : List Filter -> Cmd msg


port requestFilters : () -> Cmd msg


port filtersLoaded : (List Filter -> msg) -> Sub msg


port focus : String -> Cmd msg
