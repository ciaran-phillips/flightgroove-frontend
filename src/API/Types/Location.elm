module API.Types.Location exposing (..)


type alias Airport =
    { placeName : String
    , countryName : String
    , cityId : String
    , airportCode : String
    , latitude : Float
    , longitude : Float
    }


type alias LocationSuggestion =
    { cityId : String
    , countryId : String
    , countryName : String
    , placeId : String
    , placeName : String
    , regionId : String
    }


type alias LocationSuggestions =
    List (LocationSuggestion)


type alias Routes =
    List (Route)


type alias Route =
    { departureDate : String
    , returnDate : String
    , priceCredits : Int
    , priceDisplay : String
    , origin : Airport
    , secondOrigin : Maybe Airport
    , destination : Airport
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
