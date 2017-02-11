module API.Types.LivePricing exposing (..)


type alias PollLivePricingResponse =
    { completed : Bool
    , itineraries : List Itinerary
    , places : List Place
    , legs : List Leg
    , segments : List Segment
    , carriers : List Carrier
    }


type alias StartLivePricingResponse =
    { location : String
    }


type alias Itinerary =
    { outboundLegId : String
    , inboundLegId : String
    , pricingOptions : List (PricingOption)
    }


type alias PollingUrl =
    String


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


getLeg : List Leg -> Itinerary -> Direction -> Maybe Leg
getLeg legs itinerary direction =
    let
        needleId =
            case direction of
                Inbound ->
                    itinerary.inboundLegId

                Outbound ->
                    itinerary.outboundLegId
    in
        List.head <|
            List.filter
                (\leg -> leg.id == needleId)
                legs


getSegmentsFromLeg : Leg -> List Segment -> List Segment
getSegmentsFromLeg leg segments =
    List.filter
        (\n -> List.member n.id leg.segments)
        segments


getCarriersFromItinerary : PollLivePricingResponse -> Itinerary -> List Carrier
getCarriersFromItinerary fullFlightData itinerary =
    let
        getLegFunc =
            getLeg fullFlightData.legs itinerary

        getCarrierList =
            \leg ->
                case leg of
                    Nothing ->
                        []

                    Just l ->
                        l.carriers

        outboundCarriers =
            getLegFunc Outbound |> getCarrierList

        inboundCarriers =
            getLegFunc Inbound |> getCarrierList
    in
        List.filter
            (\carrier ->
                List.member carrier.id <|
                    (outboundCarriers ++ inboundCarriers)
            )
            fullFlightData.carriers


getCarrierFromSegment : List Carrier -> Segment -> Maybe Carrier
getCarrierFromSegment carriers flightSegment =
    List.head <|
        List.filter
            (\carrier -> carrier.id == flightSegment.carrier)
            carriers


getPlace : List Place -> Int -> Maybe Place
getPlace places placeId =
    let
        filterPlace =
            \place ->
                case place of
                    AirportTag place ->
                        place.placeId == placeId

                    CityTag place ->
                        place.placeId == placeId

                    CountryTag place ->
                        place.placeId == placeId
    in
        List.head <|
            List.filter
                filterPlace
                places
