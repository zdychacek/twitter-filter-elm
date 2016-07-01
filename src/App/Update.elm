module App.Update exposing (init, update, Msg(..))

import App.Model as App exposing (Model, Route(..), new)
import Pages.Tweets.Update as Tweets
import Pages.Filters.Update as Filters exposing (Msg(..), OutMsg(..))
import Pages.Filters.Model as Filters exposing (new)
import Pages.Tweets.Model as Tweets exposing (new)
import Filter.Model exposing (Filter)
import Ports exposing (requestFilters)


type Msg
    = SetRoute Route
    | PageTweets Tweets.Msg
    | PageFilters Filters.Msg
    | FiltersLoaded (List Filter)


init : Maybe (List Filter) -> ( Model, Cmd Msg )
init savedFilters =
    let
        filters =
            Maybe.withDefault [] savedFilters
    in
        ( App.new filters, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetRoute route ->
            ( updateActivePageModel ({ model | route = route }), requestFilters () )

        PageTweets msg ->
            let
                ( updatedTweetsPage, cmds ) =
                    Tweets.update msg model.tweetsPage
            in
                ( { model | tweetsPage = updatedTweetsPage }, Cmd.map PageTweets cmds )

        PageFilters msg ->
            let
                -- `Filters.update` returns out message
                ( updatedFiltersPage, cmds, outMsg ) =
                    Filters.update msg model.filtersPage

                updatedModel =
                    { model
                        | filtersPage = updatedFiltersPage
                        , filters = model.filters
                    }
                        |> processPageFiltersOutMsg outMsg
            in
                ( updatedModel, Cmd.map PageFilters cmds )

        FiltersLoaded filters ->
            let
                updatedModel =
                    ({ model | filters = filters })
                        |> updateActivePageModel
            in
                ( updatedModel, Cmd.none )


processPageFiltersOutMsg : OutMsg -> Model -> Model
processPageFiltersOutMsg outMsg model =
    case outMsg of
        Filters.ChangeRoute route ->
            (update (SetRoute route) model)
                |> fst

        _ ->
            model


updateFiltersPage : Model -> Int -> Model
updateFiltersPage model id =
    let
        selectedFilter =
            List.filter (\f -> id == f.id) model.filters
                |> List.head

        resetedFiltersPage =
            Filters.new model.filters

        updatedFiltersPage =
            case selectedFilter of
                Just filter ->
                    let
                        ( updatedModel, _, _ ) =
                            Filters.update (SelectFilter filter) resetedFiltersPage
                    in
                        updatedModel

                Nothing ->
                    resetedFiltersPage
    in
        { model | filtersPage = updatedFiltersPage }


updateActivePageModel : Model -> Model
updateActivePageModel model =
    case model.route of
        TweetsRoute ->
            { model | tweetsPage = Tweets.new model.filters }

        FiltersRoute ->
            { model | filtersPage = Filters.new model.filters }

        FilterRoute id ->
            updateFiltersPage model id

        NotFoundRoute ->
            model
