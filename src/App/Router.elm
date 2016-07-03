module App.Router exposing (delta2url, url2messages)

import String
import Dict
import Array
import App.Model exposing (..)
import App.Update exposing (..)
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import Erl
import Common.Messages exposing (Route(..))


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    case current.route of
        TweetsRoute filterIds ->
            let
                filters =
                    if List.length filterIds > 0 then
                        filterIds
                            |> List.map toString
                            |> String.join ","
                            |> (++) "?filters="
                    else
                        ""
            in
                Just <| UrlChange NewEntry ("/tweets" ++ filters)

        FilterRoute id ->
            Just <| UrlChange NewEntry ("/filters/" ++ toString id)

        NotFoundRoute ->
            Just <| UrlChange NewEntry "/404"



-- Changes in URL -> changes in model (messages)


url2messages : Location -> List Msg
url2messages location =
    let
        result =
            route location.href
                |> Debug.log "Router"
    in
        case result of
            Just route ->
                [ SetRoute route ]

            Nothing ->
                [ SetRoute NotFoundRoute ]


route : String -> Maybe Route
route url =
    let
        location =
            Erl.parse url

        pagePath =
            location.path
                |> List.head
                |> Maybe.withDefault "tweets"
    in
        if pagePath == "tweets" then
            String.split ","
                (Dict.get "filters" location.query
                    |> Maybe.withDefault ""
                )
                |> List.map (String.toInt >> Result.withDefault 0)
                |> List.filter ((<) 0)
                |> List.sort
                |> TweetsRoute
                |> Just

        else if pagePath == "filters" then
            (location.path
                |> Array.fromList
                |> Array.get 1
                |> Maybe.withDefault ""
            )
                |> String.toInt
                |> Result.withDefault 0
                |> FilterRoute
                |> Just

        else
            Nothing
