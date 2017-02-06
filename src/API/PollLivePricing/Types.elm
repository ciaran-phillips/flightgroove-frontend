module API.PollLivePricing.Types exposing (..)


type alias PollLivePricingResponse =
    { completed : Bool
    , itineraries : List Itinerary
    , places : List Place
    , legs : List Leg
    , segments : List Segment
    , carriers : List Carrier
    }


type alias Itinerary =
    { outboundLegId : String
    , inboundLegId : String
    , pricingOptions : List (PricingOption)
    }


type alias PollingUrl =
    String


type alias PollLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


type alias PricingOption =
    { price : Float
    , deeplink : String
    }


type Place
    = AirportTag Airport
    | CityTag City
    | CountryTag Country


type alias Country =
    { placeId : Int
    , code : String
    , name : String
    }


type alias City =
    { placeId : Int
    , parentId : Int
    , code : String
    , name : String
    }


type alias Airport =
    { placeId : Int
    , parentId : Int
    , code : String
    , name : String
    }


type alias Leg =
    { id : String
    , segments : List Int
    , originId : Int
    , destinationId : Int
    , departureTime : String
    , arrivalTime : String
    , duration : Int
    , stops : List Int
    , carriers : List Int
    , direction : Direction
    }


type Direction
    = Inbound
    | Outbound


type alias Segment =
    { id : Int
    , origin : Int
    , destination : Int
    , departureDateTime : String
    , arrivalDateTime : String
    , carrier : Int
    , duration : Int
    , flightNumber : String
    , direction : Direction
    }


type alias Carrier =
    { id : Int
    , code : String
    , name : String
    , imageUrl : String
    , displayCode : String
    }
