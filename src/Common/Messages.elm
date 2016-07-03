module Common.Messages exposing (OutMsg(..), Route(..))


type OutMsg
    = NoOp
    | ChangeRoute Route


type Route
    = TweetsRoute (List Int)
    | FilterRoute Int
    | NotFoundRoute
