module App.Update exposing (init, update, Msg(..))

import App.Model as App exposing (Model, new)
import Filter.Model exposing (Filter)
import Ports exposing (requestFilters)
import Pages.Tweets.Update as Tweets exposing (Msg(..))
import Pages.Filters.Update as Filters exposing (Msg(..))
import Components.Menu.Update as Menu exposing (Msg(..))
import Common exposing (OutMsg(..), Route(..))


type Msg
    = SetRoute Route
    | PageTweets Tweets.Msg
    | PageFilters Filters.Msg
    | FiltersLoaded (List Filter)
    | Menu Menu.Msg


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
                -- update menu component
                ( updatedMenu, _, _ ) =
                    Menu.update (Menu.SetRoute route) model.menu

                ( model, cmds ) =
                    onRouteChange ({ model | route = route, menu = updatedMenu })
            in
                ( model, Cmd.batch [ cmds, requestFilters () ] )

        PageTweets msg ->
            let
                -- `Tweets.update` returns out message
                ( updatedTweetsPage, cmds, outMsg ) =
                    Tweets.update msg model.tweetsPage

                updatedModel =
                    { model | tweetsPage = updatedTweetsPage }
                        |> processOutMsg outMsg
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
                        |> processOutMsg outMsg
            in
                ( updatedModel, Cmd.map PageFilters cmds )

        FiltersLoaded filters ->
            let
                ( updatedModel, cmds ) =
                    ({ model | filters = filters })
                        |> onRouteChange
            in
                ( updatedModel, Cmd.none )

        Menu msg ->
            let
                ( updatedMenu, cmds, outMsg ) =
                    Menu.update msg model.menu

                updatedModel =
                    { model | menu = updatedMenu }
                        |> processOutMsg outMsg
            in
                ( updatedModel, Cmd.none )



-- Called when route has changed


onRouteChange : Model -> ( Model, Cmd Msg )
onRouteChange model =
    case model.route of
        TweetsRoute filterIds ->
            let
                ( updatedModel, cmds, _ ) =
                    Tweets.update (Tweets.RestoreState filterIds model.filters) model.tweetsPage
            in
                ( { model | tweetsPage = updatedModel }, Cmd.map PageTweets cmds )

        FilterRoute id ->
            let
                ( updatedModel, cmds, _ ) =
                    Filters.update (Filters.RestoreState id model.filters) model.filtersPage
            in
                ( { model | filtersPage = updatedModel }, Cmd.map PageFilters cmds )

        NotFoundRoute ->
            ( model, Cmd.none )


processOutMsg : OutMsg -> Model -> Model
processOutMsg outMsg model =
    case outMsg of
        ChangeRoute route ->
            (update (SetRoute route) model)
                |> fst

        _ ->
            model
