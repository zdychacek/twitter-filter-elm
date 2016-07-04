module Pages.Tweets.Update exposing (init, update, Msg(..))

import Http
import String
import Task exposing (Task)
import Exts.RemoteData exposing (RemoteData(..), WebData)
import App.Model exposing (Route(..))
import Tweet.Decoder exposing (decodeTweets)
import Tweet.Model exposing (Tweet)
import Filter.Model exposing (Filter)
import Pages.Tweets.Model exposing (Model, new)
import Common.Messages exposing (OutMsg(..))


type Msg
    = AddFilter Filter
    | RemoveFilter Filter
    | FetchSucceed (List Tweet)
    | FetchFail Http.Error
    | Init (List Int) (List Filter)


init : List Filter -> ( Model, Cmd Msg )
init savedFilters =
    ( new savedFilters, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg, OutMsg )
update msg model =
    case msg of
        Init filterIds savedFilters ->
            let
                selectedFilters =
                    List.filter (\f -> List.member f.id filterIds) savedFilters

                filters =
                    List.filter (\f -> not (List.member f.id filterIds)) savedFilters

                resetedTweetsPage =
                    new savedFilters

                updatedTweets =
                    if List.length selectedFilters > 0 then
                        Loading
                    else
                        Success []

                updatedTweetsPage =
                    { resetedTweetsPage
                        | selectedFilters = selectedFilters
                        , filters = filters
                        , tweets = updatedTweets
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
                updatedSelectedFilters =
                    model.selectedFilters ++ [ filter ]

                updatedFilters =
                    model.filters
                        |> List.filter (\currFilter -> currFilter.id /= filter.id)

                updatedModel =
                    { model
                        | tweets = Loading
                        , selectedFilters = updatedSelectedFilters
                        , filters = updatedFilters
                    }

                cmd =
                    updatedModel.selectedFilters
                        |> joinFilters
                        |> fetchCommand
            in
                ( updatedModel, cmd, ChangeRoute (TweetsRoute (List.map .id updatedSelectedFilters)) )

        RemoveFilter filter ->
            let
                updatedSelectedFilters =
                    model.selectedFilters
                        |> List.filter (\currFilter -> currFilter.id /= filter.id)

                updatedFilters =
                    model.filters ++ [ filter ]

                updatedTweets =
                    if List.length updatedSelectedFilters > 0 then
                        Loading
                    else
                        Success []

                updatedModel =
                    { model
                        | tweets = updatedTweets
                        , selectedFilters = updatedSelectedFilters
                        , filters = updatedFilters
                    }

                cmd =
                    if List.length updatedModel.selectedFilters > 0 then
                        updatedModel.selectedFilters
                            |> joinFilters
                            |> fetchCommand
                    else
                        Cmd.none
            in
                ( updatedModel, cmd, ChangeRoute (TweetsRoute (List.map .id updatedSelectedFilters)) )


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
