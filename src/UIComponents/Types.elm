module UIComponents.Types exposing (..)

import Date exposing (Date)


type alias FilterCriteria =
    { locationId : String
    , outboundDate : String
    , inboundDate : String
    }
