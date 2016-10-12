module UIComponents.Types exposing (..)


type alias FilterCriteria =
    { locationId : String
    , secondOriginId : Maybe String
    , outboundDate : String
    , inboundDate : String
    }


type RemoteData err a
    = Empty
    | Loading
    | Success a
    | Failure err
