module Explorer.Model exposing (..)

import Explorer.Filters.Types exposing (FilterCriteria)
import Explorer.Sidebar.SidebarModel as SidebarModel
import Explorer.Types exposing (RemoteData(..))
import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel
import API.Response as Response
import Material
import Http
import Dict


type alias Model =
    { mapActive : Bool
    , mapData : RemoteData Http.Error Response.Routes
    , airports : Dict.Dict String Response.Airport
    , quotes : Response.Quotes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    , sidebar : Maybe SidebarModel.SidebarModel
    , flightSearch : Maybe FlightSearchModel.FlightSearchModel
    , mdl : Material.Model
    }


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = Empty
    , airports = Dict.empty
    , criteria = defaultCriteria
    , quotes = []
    , selectedDestination = Nothing
    , sidebar = Nothing
    , flightSearch = Nothing
    , mdl = Material.model
    }


defaultMapData : Response.Routes
defaultMapData =
    []


defaultCriteria : FilterCriteria
defaultCriteria =
    { locationId = "DUB-sky"
    , inboundDate = "2016-10"
    , outboundDate = "2016-10"
    }
