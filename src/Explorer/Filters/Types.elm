module Explorer.Filters.Types exposing (FilterCriteria)


type alias FilterCriteria =
    { locationId : String
    , secondOriginId : Maybe String
    , outboundDate : String
    , inboundDate : String
    }
