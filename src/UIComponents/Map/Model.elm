module UIComponents.Map.Model exposing (..)

import UIComponents.Types exposing (FilterCriteria)
import API.Response as Response


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , criteria : FilterCriteria
    , selectedDestination : Maybe String
    }


type alias PopupDefinition =
    ( String, Float, Float, String )


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    , criteria = defaultCriteria
    , selectedDestination = Nothing
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
