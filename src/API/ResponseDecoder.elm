module API.ResponseDecoder exposing (..)

import Json.Decode exposing (Decoder, int, bool, string, float, list, object1, object2, object4, object6, object5, object7, (:=))
import API.Response as Response


routesDecoder : Decoder Response.Response
routesDecoder =
    object1 Response.RoutesResponse
        (list routeDecoder)


routeDecoder : Decoder Response.Route
routeDecoder =
    object6 Response.Route
        ("departureDate" := string)
        ("returnDate" := string)
        ("priceCredits" := int)
        ("priceDisplay" := string)
        ("origin" := airportDecoder)
        ("destination" := airportDecoder)


airportDecoder : Decoder Response.Airport
airportDecoder =
    object5 Response.Airport
        ("name" := string)
        ("country" := string)
        ("code" := string)
        ("latitude" := float)
        ("longitude" := float)


suggestionDecoder : Decoder Response.LocationSuggestion
suggestionDecoder =
    object6 Response.LocationSuggestion
        ("CityId" := string)
        ("CountryId" := string)
        ("CountryName" := string)
        ("PlaceId" := string)
        ("PlaceName" := string)
        ("RegionId" := string)


locationsDecoder : Decoder Response.Response
locationsDecoder =
    object1 Response.LocationsResponse <|
        ("Places" := list suggestionDecoder)


browseDatesDecoder : Decoder Response.Response
browseDatesDecoder =
    object1 Response.BrowseDatesResponse <|
        object2 Response.BrowseDates
            ("Quotes" := quotesDecoder)
            ("Dates" := dateOptionsDecoder)


quotesDecoder : Decoder Response.Quotes
quotesDecoder =
    list quoteDecoder


quoteDecoder : Decoder Response.Quote
quoteDecoder =
    object6 Response.Quote
        ("Direct" := bool)
        ("InboundLeg" := journeyLegDecoder)
        ("MinPrice" := int)
        ("OutboundLeg" := journeyLegDecoder)
        ("QuoteDateTime" := string)
        ("QuoteId" := int)


journeyLegDecoder : Decoder Response.JourneyLeg
journeyLegDecoder =
    object4 Response.JourneyLeg
        ("CarrierIds" := list int)
        ("DepartureDate" := string)
        ("DestinationId" := int)
        ("OriginId" := int)


dateOptionsDecoder : Decoder Response.DateOptions
dateOptionsDecoder =
    ("OutboundDates" := list dateOptionDecoder)


dateOptionDecoder : Decoder Response.DateOption
dateOptionDecoder =
    object4 Response.DateOption
        ("PartialDate" := string)
        ("Price" := int)
        ("QuoteIds" := list int)
        ("QuoteDateTime" := string)
