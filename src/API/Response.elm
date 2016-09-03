module API.Response exposing (Response(..), Routes, Route, Airport, Locations, LocationSuggestion)


type Response
    = RoutesResponse Routes
    | LocationsResponse Locations


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
