module App.Router exposing (delta2url, url2messages)

import String
import App.Model exposing (..)
import App.Update exposing (..)
import Navigation exposing (Location)
import RouteUrl exposing (HistoryEntry(..), UrlChange)
import UrlParser exposing (Parser, (</>), format, int, oneOf, s, string)


routeMatchers : Parser (Route -> a) a
routeMatchers =
    oneOf
        [ format TweetsRoute (s "")
        , format TweetsRoute (s "tweets")
        , format FilterRoute (s "filters" </> int)
        , format NotFoundRoute (s "404")
        ]



-- Changes in model -> URL --


delta2url : Model -> Model -> Maybe UrlChange
delta2url previous current =
    case current.route of
        TweetsRoute ->
            Just <| UrlChange NewEntry "/tweets"

        FilterRoute id ->
            Just <| UrlChange NewEntry ("/filters/" ++ toString id)

        NotFoundRoute ->
            Just <| UrlChange NewEntry "/404"



-- Changes in URL -> changes in model (messages)


url2messages : Location -> List Msg
url2messages location =
    let
        result =
            UrlParser.parse identity routeMatchers (String.dropLeft 1 location.pathname)
    in
        case result of
            Ok route ->
                [ SetRoute route ]

            Err _ ->
                [ SetRoute NotFoundRoute ]
