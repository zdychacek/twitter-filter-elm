module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.App as Html
import Html.Events exposing (onClick)
import App.Model exposing (..)
import App.Update exposing (..)
import Pages.PageNotFound.View as PageNotFound exposing (..)
import Pages.Tweets.View as Tweets exposing (..)
import Pages.Filters.View as Filters exposing (..)


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewHeader model
        , viewMenu model
        , viewMainContent model
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "row" ]
        [ div [ class "col s12" ]
            [ h2 [] [ text "Twitter filter" ]
            ]
        ]


viewMenu : Model -> Html Msg
viewMenu model =
    div [ class "row" ]
        [ div [ class "col s12" ]
            [ nav []
                [ div [ class "nav-wrapper" ]
                    [ ul []
                        [ li []
                            [ a
                                [ classByPage TweetsRoute model.route
                                , onClick <| SetRoute TweetsRoute
                                ]
                                [ text "Tweets" ]
                            ]
                        , li []
                            [ a
                                [ classByPage FiltersRoute model.route
                                , onClick <| SetRoute FiltersRoute
                                ]
                                [ text "Filters" ]
                            ]
                        ]
                    ]
                ]
            ]
        ]



-- Render current page.


viewMainContent : Model -> Html Msg
viewMainContent model =
    case model.route of
        TweetsRoute ->
            Html.map PageTweets (Tweets.view model.tweetsPage)

        FiltersRoute ->
            Html.map PageFilters (Filters.view model.filtersPage)

        FilterRoute _ ->
            Html.map PageFilters (Filters.view model.filtersPage)

        NotFoundRoute ->
            PageNotFound.view


{-| Get menu items classes. This function gets the active page and checks if
it is indeed the page used.
-}
classByPage : Route -> Route -> Attribute a
classByPage route currentRoute =
    classList
        [ ( "active", route == currentRoute )
        ]
