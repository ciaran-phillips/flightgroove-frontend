module Explorer.Model exposing (..)

import Explorer.Filters.Types exposing (FilterCriteria)
import Explorer.Sidebar.SidebarModel as SidebarModel
import Explorer.Types exposing (RemoteData(..))
import Explorer.Commands as Commands
import Explorer.Messages as Messages
import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel
import API.LocationTypes as LocationTypes
import API.DateGridTypes as DateGridTypes
import Explorer.Filters.Filters as Filters
import Material
import Http
import Dict


type alias Model =
    { mapActive : Bool
    , mapData : RemoteData Http.Error LocationTypes.Routes
    , filtersModel : Filters.Model
    , airports : Dict.Dict String LocationTypes.Airport
    , quotes : DateGridTypes.Quotes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    , sidebar : Maybe SidebarModel.SidebarModel
    , flightSearch : Maybe FlightSearchModel.FlightSearchModel
    , mdl : Material.Model
    }


init : String -> ( Model, Cmd Messages.Msg )
init initialMonth =
    let
        ( filtersModel, filtersCmd ) =
            Filters.init initialMonth
    in
        ( { mapActive = False
          , mapData = Empty
          , filtersModel = filtersModel
          , airports = Dict.empty
          , criteria = Filters.defaultCriteria initialMonth
          , quotes = []
          , selectedDestination = Nothing
          , sidebar = Nothing
          , flightSearch = Nothing
          , mdl = Material.model
          }
        , Cmd.batch
            [ Cmd.map Messages.FilterTag filtersCmd
            , Commands.initialCmd
            ]
        )


defaultMapData : LocationTypes.Routes
defaultMapData =
    []
