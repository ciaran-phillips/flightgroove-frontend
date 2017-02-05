module API.PollLivePricing exposing (..)

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import Http
import Task
import Dict exposing (Dict)


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


pollLivePricing : PollingUrl -> PollLivePricingParams -> Task.Task Http.Error PollLivePricingResponse
pollLivePricing url params =
    Http.get pollLivePricingDecoder <|
        buildUrl url params


pollLivePricingDecoder : Decode.Decoder PollLivePricingResponse
pollLivePricingDecoder =
    Decode.object6 PollLivePricingResponse
        (("status" := Decode.string) `Decode.andThen` statusDecoder)
        ("itineraries" := list itineraryDecoder)
        ("places" := list placeDecoder)
        ("legs" := list legDecoder)
        ("segments" := list segmentDecoder)
        ("carriers" := list carrierDecoder)


statusDecoder : String -> Decode.Decoder Bool
statusDecoder status =
    case status of
        "UpdatesPending" ->
            succeed False

        "UpdatesComplete" ->
            succeed True

        _ ->
            succeed True


itineraryDecoder : Decode.Decoder Itinerary
itineraryDecoder =
    Decode.object3 Itinerary
        ("outboundLegId" := string)
        ("inboundLegId" := string)
        ("pricingOptions" := list pricingOptionDecoder)


placeDecoder : Decode.Decoder Place
placeDecoder =
    oneOf [ airportDecoder, cityDecoder, countryDecoder ]


countryDecoder : Decode.Decoder Place
countryDecoder =
    Decode.object3
        ((\a b c -> CountryTag <| Country a b c))
        ("id" := int)
        ("code" := string)
        ("name" := string)


cityDecoder : Decode.Decoder Place
cityDecoder =
    Decode.object4
        ((\a b c d -> CityTag <| City a b c d))
        ("id" := int)
        ("parentId" := int)
        ("code" := string)
        ("name" := string)


airportDecoder : Decode.Decoder Place
airportDecoder =
    Decode.object4
        ((\a b c d -> AirportTag <| Airport a b c d))
        ("id" := int)
        ("parentId" := int)
        ("code" := string)
        ("name" := string)


pricingOptionDecoder : Decode.Decoder PricingOption
pricingOptionDecoder =
    Decode.object2 PricingOption
        ("price" := float)
        ("deeplinkUrl" := string)


legDecoder : Decode.Decoder Leg
legDecoder =
    Decode.succeed Leg
        |: ("id" := string)
        |: ("segmentIds" := list int)
        |: ("originStation" := int)
        |: ("destinationStation" := int)
        |: ("departure" := string)
        |: ("arrival" := string)
        |: ("duration" := int)
        |: ("stops" := list int)
        |: ("carriers" := list int)
        |: (("directionality" := string) `Decode.andThen` directionDecoder)


segmentDecoder : Decode.Decoder Segment
segmentDecoder =
    Decode.succeed Segment
        |: ("id" := int)
        |: ("originStation" := int)
        |: ("destinationStation" := int)
        |: ("departureDateTime" := string)
        |: ("arrivalDateTime" := string)
        |: ("carrier" := int)
        |: ("duration" := int)
        |: ("flightNumber" := string)
        |: (("directionality" := string) `Decode.andThen` directionDecoder)


carrierDecoder : Decode.Decoder Carrier
carrierDecoder =
    Decode.object5 Carrier
        ("id" := int)
        ("code" := string)
        ("name" := string)
        ("imageUrl" := string)
        ("displayCode" := string)


directionDecoder : String -> Decode.Decoder Direction
directionDecoder direction =
    case direction of
        "Inbound" ->
            succeed Inbound

        "Outbound" ->
            succeed Outbound

        _ ->
            fail "Direction was not 'Inbound' or 'Outbound'"


buildUrl : PollingUrl -> PollLivePricingParams -> String
buildUrl url params =
    "/api/livepricing/poll/"
        ++ (Http.uriEncode url)
        ++ "?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
        ++ ("&originplace=" ++ params.origin)
        ++ ("&destinationplace=" ++ params.destination)
        ++ ("&outbounddate=" ++ params.outboundDate)
        ++ ("&inbounddate=" ++ params.inboundDate)



-- Manipulating Response


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
