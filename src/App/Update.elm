module App.Update exposing (init, update, Msg(..))

import App.Model as App exposing (Model, Route(..), new)
import Filter.Model exposing (Filter)
import Ports exposing (requestFilters)
import Pages.Tweets.Update as Tweets exposing (Msg(..))
import Pages.Filters.Update as Filters exposing (Msg(..))
import Common.Messages exposing (OutMsg(..))


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
            let
                ( model, cmds ) =
                    initActivePage ({ model | route = route })
            in
                ( model, Cmd.batch [ cmds, requestFilters () ] )

        PageTweets msg ->
            let
                -- `Tweets.update` returns out message
                ( updatedTweetsPage, cmds, outMsg ) =
                    Tweets.update msg model.tweetsPage

                updatedModel =
                    { model | tweetsPage = updatedTweetsPage }
                        |> processPageOutMsg outMsg
            in
                ( updatedModel, Cmd.map PageTweets cmds )

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
                        |> processPageOutMsg outMsg
            in
                ( updatedModel, Cmd.map PageFilters cmds )

        FiltersLoaded filters ->
            let
                ( updatedModel, cmds ) =
                    ({ model | filters = filters })
                        |> initActivePage
            in
                ( updatedModel, Cmd.none )


initActivePage : Model -> ( Model, Cmd Msg )
initActivePage model =
    case model.route of
        TweetsRoute filterIds ->
            let
                ( updatedModel, cmds, _ ) =
                    Tweets.update (Tweets.Init filterIds model.filters) model.tweetsPage
            in
                ( { model | tweetsPage = updatedModel }, Cmd.map PageTweets cmds )

        FilterRoute id ->
            let
                ( updatedModel, cmds, _ ) =
                    Filters.update (Filters.Init id model.filters) model.filtersPage
            in
                ( { model | filtersPage = updatedModel }, Cmd.map PageFilters cmds )

        NotFoundRoute ->
            ( model, Cmd.none )


processPageOutMsg : OutMsg -> Model -> Model
processPageOutMsg outMsg model =
    case outMsg of
        ChangeRoute route ->
            (update (SetRoute route) model)
                |> fst

        _ ->
            model
