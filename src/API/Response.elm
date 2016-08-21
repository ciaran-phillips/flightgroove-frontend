module API.Response exposing (..)


type alias RoutesResponse =
    { ageOfData : String
    , destinationList : List (Destination)
    }


type alias Destination =
    { name : String
    , country : String
    , airport : String
    , priceDisplay : String
    , priceCredits : Int
    , location : Location
    }


type alias Location =
    { lat : Float
    , lon : Float
    }
