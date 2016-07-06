module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, classList)
import Html.App exposing (map)
import Html.Events exposing (onClick)
import App.Model exposing (Model)
import App.Update exposing (..)
import Pages.PageNotFound.View as PageNotFound exposing (..)
import Pages.Tweets.View as Tweets exposing (..)
import Pages.Filters.View as Filters exposing (..)
import Components.Menu.View as Menu
import Common exposing (Route(..))

view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ viewHeader model
        , map Menu (Menu.view model.menu)
        , viewMainContent model
        , pre []
            [ text (toString model) ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    div [ class "row" ]
        [ div [ class "col s12" ]
            [ h2 [] [ text "Twitter filter" ]
            ]
        ]


-- Render current page.
viewMainContent : Model -> Html Msg
viewMainContent model =
    case model.route of
        TweetsRoute _ ->
            map PageTweets (Tweets.view model.tweetsPage)

        FilterRoute _ ->
            map PageFilters (Filters.view model.filtersPage)

        NotFoundRoute ->
            PageNotFound.view
