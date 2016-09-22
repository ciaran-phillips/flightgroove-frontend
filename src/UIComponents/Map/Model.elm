module UIComponents.Map.Model exposing (..)

import UIComponents.Types exposing (FilterCriteria)
import UIComponents.Map.Types exposing (..)
import API.Response as Response
import Material


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , quotes : Response.Quotes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    , sidebar : Maybe SidebarModel
    , mdl : Material.Model
    }


type alias SidebarModel =
    { dateGrid : RemoteData Response.DateGrid
    , gridPosition : GridPosition
    , gridSize : GridSize
    , destination : String
    , lowestPrice : String
    , selectedOutboundDate : String
    , selectedInboundDate : String
    , activeTab : Int
    }


type alias GridSize =
    { rows : Int
    , columns : Int
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


newSidebarModel : String -> String -> String -> String -> SidebarModel
newSidebarModel destination outboundDate inboundDate lowestPrice =
    { dateGrid = Empty
    , gridPosition = { x = 0, y = 0 }
    , gridSize = { rows = 0, columns = 0 }
    , destination = destination
    , selectedOutboundDate = outboundDate
    , selectedInboundDate = inboundDate
    , lowestPrice = lowestPrice
    , activeTab = 0
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


getGridSize : Response.DateGrid -> GridSize
getGridSize grid =
    { rows = List.length grid.columnHeaders
    , columns = List.length grid.rows
    }
