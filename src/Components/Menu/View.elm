module Components.Menu.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.Events exposing (onClick)
import Components.Menu.Model exposing (Model)
import Components.Menu.Update exposing (Msg(..))


view : Model -> Html Msg
view model =
    let
        createItem (idx, item) =
            li []
                [ a
                    [ classList [ ( "active", idx == model.selectedIndex ) ]
                    , onClick (SetRoute item.route)
                    ]
                    [ text item.text ]
                ]

        list =
            model.items
                |> List.indexedMap (,)
                |> List.map createItem
    in
        div [ class "row" ]
            [ div [ class "col s12" ]
                [ nav []
                    [ div [ class "nav-wrapper" ]
                        [ ul []
                            list
                        ]
                    ]
                ]
            ]
