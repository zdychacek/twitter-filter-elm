module Components.Menu.Update exposing (Msg(..), update)

import Components.Menu.Model exposing (Model, MenuItem)
import Common exposing (OutMsg(..), Route(..))


type Msg =
    SetRoute Route


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg)
update msg model =
    case msg of
        SetRoute route ->
            let
                index =
                    case route of
                        TweetsRoute _ ->
                            0

                        FilterRoute _ ->
                            1

                        _ ->
                            0
            in
                ( { model | selectedIndex = index }, Cmd.none, ChangeRoute route )
