module API.Response exposing (..)


type Response
    = RoutesResponse Routes
    | LocationsResponse Locations
    | DateGridResponse DateGrid


type alias Routes =
    List (Route)


type alias Route =
    { departureDate : String
    , returnDate : String
    , priceCredits : Int
    , priceDisplay : String
    , origin : Airport
    , destination : Airport
    }


type alias Airport =
    { placeName : String
    , countryName : String
    , cityId : String
    , airportCode : String
    , latitude : Float
    , longitude : Float
    }


type alias Locations =
    List (LocationSuggestion)


type alias LocationSuggestion =
    { cityId : String
    , countryId : String
    , countryName : String
    , placeId : String
    , placeName : String
    , regionId : String
    }


type alias BrowseDates =
    { quotes : Quotes
    , dateOptions : DateOptions
    }


type alias QuoteId =
    Int


type alias DateOptions =
    List (DateOption)


type alias DateOption =
    { partialDate : String
    , price : Int
    , quoteIds : List (QuoteId)
    , quoteDateTime : String
    }


type alias Quotes =
    List (Quote)


type alias Quote =
    { direct : Bool
    , inboundLeg : JourneyLeg
    , minPrice : Int
    , outboundLeg : JourneyLeg
    , quoteDateTime : String
    , quoteId : QuoteId
    }


type alias JourneyLeg =
    { carrierIds : List (Int)
    , departureDate : String
    , destinationNumericId : Int
    , originNumericId : Int
    }


type alias DateGrid =
    { columnHeaders : List (Maybe String)
    , rows : List (DateGridRow)
    }


type alias DateGridRow =
    { rowHeader : String
    , cells : List (Maybe DateGridCell)
    }


type alias DateGridCell =
    { priceCredits : Int
    , priceDisplay : String
    , outboundDate : String
    , inboundDate : String
    }


getRoutesForLocation : Routes -> String -> Routes
getRoutesForLocation routes locationId =
    let
        filterFunc =
            \n -> n.destination.airportCode == locationId
    in
        List.filter filterFunc routes


getCheapestRouteForDestination : Routes -> String -> Maybe Route
getCheapestRouteForDestination routes destination =
    getRoutesForLocation routes destination
        |> List.sortBy .priceCredits
        |> List.head
