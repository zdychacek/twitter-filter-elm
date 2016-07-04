module Common.Messages exposing (OutMsg(..))

import App.Model exposing (Route(..))


type OutMsg
    = NoOp
    | ChangeRoute Route
