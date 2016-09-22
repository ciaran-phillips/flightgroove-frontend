module UIComponents.Map.Model exposing (..)

import UIComponents.Types exposing (FilterCriteria)
import API.Response as Response
import Material


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , dateGrid : Maybe Response.DateGrid
    , gridPosition : GridPosition
    , quotes : Response.Quotes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    , selectedOutboundDate : Maybe String
    , selectedInboundDate : Maybe String
    , activeTab : Int
    , mdl : Material.Model
    }


type alias PopupDefinition =
    ( String, Float, Float, String )


type alias GridPosition =
    { x : Int
    , y : Int
    }


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    , criteria = defaultCriteria
    , dateGrid = Nothing
    , gridPosition = { x = 0, y = 0 }
    , quotes = []
    , selectedDestination = Nothing
    , selectedOutboundDate = Nothing
    , selectedInboundDate = Nothing
    , mdl = Material.model
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
