module UIComponents.Types exposing (..)


type alias FilterCriteria =
    { locationId : String
    , outboundDate : String
    , inboundDate : String
    }


type RemoteData a
    = Empty
    | Loading
    | Success a
    | Failure a
