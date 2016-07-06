module Pages.Tweets.Update exposing (init, update, Msg(..))

import Http
import String
import Task exposing (Task)
import Exts.RemoteData exposing (RemoteData(..), WebData)
import Tweet.Decoder exposing (decodeTweets)
import Tweet.Model exposing (Tweet)
import Filter.Model exposing (Filter)
import Pages.Tweets.Model exposing (Model, new)
import Common exposing (Route(..), OutMsg(..))


type Msg
    = AddFilter Filter
    | RemoveFilter Filter
    | FetchSucceed (List Tweet)
    | FetchFail Http.Error
    | RestoreState (List Int) (List Filter)


init : List Filter -> ( Model, Cmd Msg )
init savedFilters =
    ( new savedFilters, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        RestoreState filterIds savedFilters ->
            let
                selectedFilters =
                    List.filter (\f -> List.member f.id filterIds) savedFilters

                filters =
                    List.filter (\f -> not (List.member f.id filterIds)) savedFilters

                resetedTweetsPage =
                    new savedFilters

                hasSelectedFilters =
                    List.length selectedFilters > 0

                updatedTweetsPage =
                    { resetedTweetsPage
                        | selectedFilters = selectedFilters
                        , filters = filters
                        , tweets = if hasSelectedFilters then Loading else Success []
                    }

                cmd =
                    if List.length selectedFilters > 0 then
                        selectedFilters
                            |> joinFilters
                            |> fetchCommand
                    else
                        Cmd.none
            in
                ( updatedTweetsPage, cmd, NoOp )

        FetchSucceed tweets ->
            ( { model | tweets = Success tweets }, Cmd.none, NoOp )

        FetchFail _ ->
            ( model, Cmd.none, NoOp )

        AddFilter filter ->
            let
                updatedModel =
                    { model | tweets = Loading }
                        |> addFilter filter

                cmd =
                    updatedModel.selectedFilters
                        |> joinFilters
                        |> fetchCommand
            in
                ( updatedModel, cmd, ChangeRoute (TweetsRoute (List.map .id updatedModel.selectedFilters)) )

        RemoveFilter filter ->
            let
                updatedModel =
                    removeFilter filter model

                hasSelectedFilters =
                    List.length updatedModel.selectedFilters > 0

                cmd =
                    if hasSelectedFilters then
                        updatedModel.selectedFilters
                            |> joinFilters
                            |> fetchCommand
                    else
                        Cmd.none
            in
                ( { updatedModel | tweets = if hasSelectedFilters then Loading else Success [] }
                , cmd
                , ChangeRoute (TweetsRoute (List.map .id updatedModel.selectedFilters))
                )


fetchCommand : String -> Cmd Msg
fetchCommand query =
    let
        getTweets : Task Http.Error (List Tweet)
        getTweets =
            Http.get decodeTweets ("/api/twitter/search/tweets.json?q=" ++ query ++ " filter:media -filter:retweets")
    in
        Task.perform FetchFail FetchSucceed getTweets



-- join filters' labels
joinFilters : List Filter -> String
joinFilters filters =
    filters
        |> List.map (\currFilter -> String.join " OR " currFilter.tags)
        |> String.join " "


addFilter : Filter -> Model -> Model
addFilter filter model =
    let
        updatedSelectedFilters =
            model.selectedFilters ++ [ filter ]

        updatedFilters =
            model.filters
                |> List.filter (\currFilter -> currFilter.id /= filter.id)

        updatedModel =
            { model
                | selectedFilters = updatedSelectedFilters
                , filters = updatedFilters
            }
    in
        updatedModel


removeFilter : Filter -> Model -> Model
removeFilter filter model =
    let
        updatedSelectedFilters =
            model.selectedFilters
                |> List.filter (\currFilter -> currFilter.id /= filter.id)

        updatedModel =
            { model
                | selectedFilters = updatedSelectedFilters
                , filters = model.filters ++ [ filter ]
            }
    in
        updatedModel
