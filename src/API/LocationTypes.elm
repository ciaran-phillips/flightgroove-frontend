module API.LocationTypes exposing (..)


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
    , destination : Airport
    }
