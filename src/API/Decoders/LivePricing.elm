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
    Decode.object6 PollLivePricingResponse
        (("status" := Decode.string) `Decode.andThen` statusDecoder)
        ("itineraries" := list itineraryDecoder)
        ("places" := list placeDecoder)
        ("legs" := list legDecoder)
        ("segments" := list segmentDecoder)
        ("carriers" := list carrierDecoder)


startLivePricingResponse : Decode.Decoder StartLivePricingResponse
startLivePricingResponse =
    Decode.object1 StartLivePricingResponse
        ("location" := Decode.string)


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
        (oneOf [ ("deeplinkUrl" := string), (succeed "") ])


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
