module UIComponents.Types exposing (..)

import Date exposing (Date)


type alias FilterCriteria =
    { locationId : String
    , outboundDate : Maybe Date
    , inboundDate : Maybe Date
    }
