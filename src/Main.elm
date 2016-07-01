module Main exposing (..)

import App.Model exposing (Model)
import App.Router exposing (..)
import App.Update exposing (init, update, Msg(..))
import App.View exposing (view)
import RouteUrl
import Filter.Model exposing (Filter)
import Ports exposing (filtersLoaded)
import TimeTravel.Navigation as TimeTravel


app : RouteUrl.NavigationApp Model Msg (Maybe (List Filter))
app =
    RouteUrl.navigationAppWithFlags
        { delta2url = delta2url
        , location2messages = url2messages
        , init = App.Update.init
        , update = App.Update.update
        , view = App.View.view
        , subscriptions = subscriptions
        }


main : Program (Maybe (List Filter.Model.Filter))
main =
    TimeTravel.programWithFlags app.parser
        { init = app.init
        , update = app.update
        , urlUpdate = app.urlUpdate
        , view = app.view
        , subscriptions = app.subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    filtersLoaded FiltersLoaded
