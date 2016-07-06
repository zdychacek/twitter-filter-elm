port module Pages.Filters.Update exposing (init, update, Msg(..))

import String
import Pages.Filters.Model exposing (Model, new)
import Filter.Model exposing (Filter)
import Ports exposing (focus, saveFilters, requestFilters)
import Common exposing (Route(..), OutMsg(..))


type Msg
    = SetName String
    | SetTags String
    | SelectFilter Filter
    | EraseForm
    | SaveFilter
    | DeleteFilter
    | Init Int (List Filter)


init : List Filter -> ( Model, Cmd Msg )
init savedFilters =
    ( new savedFilters, Cmd.none )

update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        Init id savedFilters ->
            let
                selectedFilter =
                    List.filter (\f -> id == f.id) savedFilters
                        |> List.head

                resetedFiltersPage =
                    new savedFilters

                updatedFiltersPage =
                    case selectedFilter of
                        Just filter ->
                            let
                                ( updatedModel, cmds, _ ) =
                                    update (SelectFilter filter) resetedFiltersPage
                            in
                                updatedModel

                        Nothing ->
                            resetedFiltersPage
            in
                ( updatedFiltersPage, Cmd.none, NoOp )


        SetName name ->
            ( { model | name = name }, Cmd.none, NoOp )

        SetTags strTags ->
            let
                tags =
                    String.split "," strTags
            in
                ( { model | tags = tags }, Cmd.none, NoOp )

        EraseForm ->
            let
                updatedModel =
                    { model
                        | selectedFilter = Nothing
                        , name = ""
                        , tags = []
                    }
            in
                ( updatedModel, Cmd.none, ChangeRoute (FilterRoute 0) )

        SelectFilter filter ->
            let
                updatedModel =
                    { model
                        | selectedFilter = Just filter
                        , name = filter.name
                        , tags = filter.tags
                    }
            in
                ( updatedModel, focus "#filter-name", ChangeRoute (FilterRoute filter.id) )

        SaveFilter ->
            let
                filterToSave =
                    case model.selectedFilter of
                        Just filter ->
                            Filter filter.id model.name model.tags

                        Nothing ->
                            let
                                newId =
                                    model.filters
                                        |> List.map .id
                                        |> List.maximum
                                        |> Maybe.withDefault 0
                            in
                                Filter (newId + 1) model.name model.tags

                updatedModel =
                    saveFilter filterToSave model
            in
                withsaveFilters ( updatedModel, requestFilters (), ChangeRoute (FilterRoute filterToSave.id) )

        DeleteFilter ->
            let
                updatedFilters =
                    case model.selectedFilter of
                        Just filter ->
                            List.filter (\currFilter -> currFilter.id /= filter.id) model.filters

                        Nothing ->
                            model.filters

                updatedModel =
                    { model
                        | filters = updatedFilters
                        , selectedFilter = Nothing
                        , name = ""
                        , tags = []
                    }
            in
                withsaveFilters ( updatedModel, requestFilters (), ChangeRoute (FilterRoute 0) )


saveFilter : Filter -> Model -> Model
saveFilter filterToSave model =
    case model.selectedFilter of
        -- Editing existing filter
        Just filter ->
            let
                updatedFilters =
                    List.map
                        (\currFilter ->
                            if currFilter.id == filter.id then
                                filterToSave
                            else
                                currFilter
                        )
                        model.filters
            in
                { model
                    | filters = updatedFilters
                    , selectedFilter = Just filterToSave
                }

        -- Creating new filter
        Nothing ->
            { model
                | filters = model.filters ++ [ filterToSave ]
                , selectedFilter = Just filterToSave
            }


withsaveFilters : ( Model, Cmd Msg, OutMsg ) -> ( Model, Cmd Msg, OutMsg )
withsaveFilters ( model, cmds, outMsg ) =
    ( model, Cmd.batch [ saveFilters model.filters, cmds ], outMsg )
