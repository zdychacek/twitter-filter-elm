module Pages.Filters.View exposing (view)

import Html exposing (..)
import Html.Lazy exposing (lazy, lazy2)
import Html.Attributes exposing (attribute, class, classList, disabled, for, id, type', title, value)
import Html.Events exposing (onClick, onInput)
import String
import Maybe.Extra exposing (isNothing)
import Pages.Filters.Update exposing (..)
import Pages.Filters.Model exposing (..)
import Filter.Model exposing (Filter)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "row" ]
            [ div [ class "col s12" ]
                [ h3 []
                    [ text "Filters" ]
                ]
            ]
        , div [ class "row" ]
            [ div [ class "col s3" ]
                [ h4 []
                    [ text "Your filters" ]
                , lazy2 viewFilterList model.filters model.selectedFilter
                  -- FilterList onFilterItemClick, items
                ]
            , div [ class "col s9" ]
                [ h4 []
                    [ text "Filter edit" ]
                , div [ class "items-block filter-form" ]
                    [ lazy viewFilterForm model
                      -- FilterForm filter={this.state.editedFilter} onDelete={this._deleteFilter} onSave={this._handleUpdateFilter}
                    ]
                ]
            ]
        ]


viewFilterForm : Model -> Html Msg
viewFilterForm model =
    let
        hasName =
            model.name
                |> String.trim
                |> String.length
                |> (/=) 0

        hasTags =
            List.length model.tags > 0

        saveBtnClassNames =
            [ ( "waves-effect waves-light btn btn--my", True )
            , ( "disabled", not hasName )
            ]

        additionalButtons =
            case model.selectedFilter of
                Just _ ->
                    [ button
                        [ onClick DeleteFilter
                        , class "waves-effect waves-light btn btn--my"
                        ]
                        [ text "Delete" ]
                    , button
                        [ onClick EraseForm
                        , class "waves-effect waves-light btn btn--my"
                        ]
                        [ text "New filter" ]
                    ]

                Nothing ->
                    []

        buttons =
            [ button
                ([ classList saveBtnClassNames
                 , disabled (not hasName)
                 ]
                    ++ if hasName == True then
                        [ onClick SaveFilter ]
                       else
                        []
                )
                [ text "Save" ]
            ]
                ++ additionalButtons
    in
        div []
            [ div [ class "row" ]
                [ div [ class "input-field input-field--my col s5" ]
                    [ input
                        [ onInput SetName
                        , value model.name
                        , id "filter-name"
                        , type' "text"
                        ]
                        []
                    , label
                        [ for "filter_name"
                        , classList [ ( "active", hasTags ) ]
                        ]
                        [ text "Filter name" ]
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "input-field input-field--my col s5" ]
                    [ input
                        [ onInput SetTags
                        , value (String.join "," model.tags)
                        , type' "text"
                        ]
                        []
                    , label
                        [ for "filter_tags"
                        , classList [ ( "active", hasTags ) ]
                        ]
                        [ text "Tags (comma separated \"elm,elmlang\")" ]
                    ]
                ]
            , div [ class "row" ]
                [ div [ class "col s12 form-controls" ]
                    buttons
                ]
            ]



-- refactor into separate component


viewFilterList : List Filter -> Maybe Filter -> Html Msg
viewFilterList filters selectedFilter =
    let
        viewFilter filter =
            let
                isSelected =
                    Maybe.Extra.mapDefault False
                        (\f ->
                            if f.id == filter.id then
                                True
                            else
                                False
                        )
                        selectedFilter
            in
                div
                    [ onClick (SelectFilter filter)
                    , classList
                        [ ( "chip filter-list__filter", True )
                        , ( "selected", isSelected )
                        ]
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
