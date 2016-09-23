module UIComponents.Map.Model exposing (..)

import UIComponents.Types exposing (FilterCriteria)
import UIComponents.Map.Types exposing (..)
import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Types exposing (RemoteData(..))
import API.Response as Response
import Material


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , quotes : Response.Quotes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    , sidebar : Maybe SidebarModel.SidebarModel
    , mdl : Material.Model
    }


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    , criteria = defaultCriteria
    , quotes = []
    , selectedDestination = Nothing
    , sidebar = Nothing
    , mdl = Material.model
    }


defaultMapData : Response.Routes
defaultMapData =
    []


defaultCriteria : FilterCriteria
defaultCriteria =
    { locationId = "DUB-sky"
    , inboundDate = "2016-09"
    , outboundDate = "2016-09"
    }
