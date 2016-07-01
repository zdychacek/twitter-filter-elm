module Filter.Model exposing (Filter)


type alias Filter =
    { id : Int
    , name : String
    , tags : List String
    }
