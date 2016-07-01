module Pages.Tweets.View exposing (view)

import Html exposing (..)
import Html.Lazy exposing (lazy)
import Html.Attributes exposing (attribute, class, href, type', src, style, target, title)
import Html.Events exposing (onClick)
import Exts.RemoteData exposing (RemoteData(..), WebData)
import Pages.Tweets.Update exposing (..)
import Pages.Tweets.Model exposing (..)
import Tweet.Model exposing (Tweet)
import Filter.Model exposing (Filter)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "col s12" ]
                [ h3 []
                    [ text "Tweets" ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col s12" ]
                [ h4 []
                    [ text "Search filters" ]
                , lazy viewSelectedFilterList model.selectedFilters
                  -- AppliedFilterList onFilterRemove, items
                ]
            ]
        , div []
            [ div [ class "row" ]
                [ div [ class "col s3" ]
                    [ h4 []
                        [ text "Filters" ]
                    , lazy viewFilterList model.filters
                      -- FilterList onFilterItemClick, items
                    ]
                , div [ class "col s9" ]
                    [ h4 []
                        [ text "Found tweets" ]
                    , lazy viewTweetsList model.tweets
                    ]
                ]
            ]
        ]


viewTweetsList : WebData (List Tweet) -> Html Msg
viewTweetsList tweets =
    let
        viewTweet tweet =
            li [ class "collection-item collection-item--my" ]
                [ div [ class "image-list__image" ]
                    [ div [ class "image__inner-column" ]
                        [ a [ href tweet.url, target "_blank" ]
                            [ img [ class "circle-border", attribute "height" "150", src tweet.url, attribute "width" "150" ]
                                []
                            ]
                        ]
                    , div [ class "image__inner-column image-description" ]
                        [ strong [ class "title" ]
                            [ text "Text:" ]
                        , p []
                            [ text tweet.text ]
                        ]
                    ]
                ]

        noTweetsMessage =
            text "No tweets found or no filter defined. Jeesus :("

        content =
            case tweets of
                NotAsked ->
                    noTweetsMessage

                Success tweets ->
                    if List.length tweets > 0 then
                        ul [ class "collection collection--my" ]
                            (List.map viewTweet tweets)
                    else
                        noTweetsMessage

                Loading ->
                    viewLoaderBar

                Failure error ->
                    error
                        |> toString
                        |> text
    in
        div [ class "items-block image-list" ]
            [ content ]



-- refactor into separate component


viewFilterList : List Filter -> Html Msg
viewFilterList filters =
    let
        viewFilter filter =
            div
                [ onClick (AddFilter filter)
                , class "chip filter-list__filter"
                , title "Add to search"
                ]
                [ text filter.name ]

        content =
            if List.length filters > 0 then
                List.map viewFilter filters
            else
                [ text "No filters to add." ]
    in
        div [ class "filter-list items-block" ]
            content


viewSelectedFilterList : List Filter -> Html Msg
viewSelectedFilterList filters =
    let
        viewFilter filter =
            div
                [ onClick (RemoveFilter filter)
                , class "chip applied-filter-list__filter"
                , title "Remove filter from search"
                ]
                [ text filter.name ]

        content =
            if List.length filters > 0 then
                List.map viewFilter filters
            else
                [ text "No filters used." ]
    in
        div [ class "applied-filter-list items-block" ]
            content


viewLoaderBar : Html Msg
viewLoaderBar =
    div [ style [ ( "textAlign", "center" ) ] ]
        [ div [ class "progress" ]
            [ div [ class "indeterminate" ] [] ]
        , strong []
            [ text "Fetching tweets dude, chill out ..." ]
        ]
