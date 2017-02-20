module API.Decoders.LivePricing
    exposing
        ( pollLivePricingResponse
        , startLivePricingResponse
        )

import Json.Decode as Decode exposing (..)
import Json.Decode.Extra exposing ((|:))
import API.Types.LivePricing exposing (..)


pollLivePricingResponse : Decode.Decoder PollLivePricingResponse
pollLivePricingResponse =
    Decode.map6 PollLivePricingResponse
        ((field "status" Decode.string) |> Decode.andThen statusDecoder)
        (field "itineraries" (list itineraryDecoder))
        (field "places" (list placeDecoder))
        (field "legs" (list legDecoder))
        (field "segments" (list segmentDecoder))
        (field "carriers" (list carrierDecoder))


startLivePricingResponse : Decode.Decoder StartLivePricingResponse
startLivePricingResponse =
    Decode.map StartLivePricingResponse
        (field "location" Decode.string)


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
    Decode.map3 Itinerary
        (field "outboundLegId" string)
        (field "inboundLegId" string)
        (field "pricingOptions" (list pricingOptionDecoder))


placeDecoder : Decode.Decoder Place
placeDecoder =
    oneOf [ airportDecoder, cityDecoder, countryDecoder ]


countryDecoder : Decode.Decoder Place
countryDecoder =
    Decode.map3
        ((\a b c -> CountryTag <| Country a b c))
        (field "id" int)
        (field "code" string)
        (field "name" string)


cityDecoder : Decode.Decoder Place
cityDecoder =
    Decode.map4
        ((\a b c d -> CityTag <| City a b c d))
        (field "id" int)
        (field "parentId" int)
        (field "code" string)
        (field "name" string)


airportDecoder : Decode.Decoder Place
airportDecoder =
    Decode.map4
        ((\a b c d -> AirportTag <| Airport a b c d))
        (field "id" int)
        (field "parentId" int)
        (field "code" string)
        (field "name" string)


pricingOptionDecoder : Decode.Decoder PricingOption
pricingOptionDecoder =
    Decode.map2 PricingOption
        (field "price" float)
        (oneOf [ (field "deeplinkUrl" string), (succeed "") ])


legDecoder : Decode.Decoder Leg
legDecoder =
    Decode.succeed Leg
        |: (field "id" string)
        |: (field "segmentIds" (list int))
        |: (field "originStation" int)
        |: (field "destinationStation" int)
        |: (field "departure" string)
        |: (field "arrival" string)
        |: (field "duration" int)
        |: (field "stops" (list int))
        |: (field "carriers" (list int))
        |: ((field "directionality" string) |> Decode.andThen directionDecoder)


segmentDecoder : Decode.Decoder Segment
segmentDecoder =
    Decode.succeed Segment
        |: (field "id" int)
        |: (field "originStation" int)
        |: (field "destinationStation" int)
        |: (field "departureDateTime" string)
        |: (field "arrivalDateTime" string)
        |: (field "carrier" int)
        |: (field "duration" int)
        |: (field "flightNumber" string)
        |: ((field "directionality" string) `Decode.andThen` directionDecoder)


carrierDecoder : Decode.Decoder Carrier
carrierDecoder =
    Decode.map5 Carrier
        (field "id" int)
        (field "code" string)
        (field "name" string)
        (field "imageUrl" string)
        (field "displayCode" string)


directionDecoder : String -> Decode.Decoder Direction
directionDecoder direction =
    case direction of
        "Inbound" ->
            succeed Inbound

        "Outbound" ->
            succeed Outbound

        _ ->
            fail "Direction was not 'Inbound' or 'Outbound'"
