module API.LocationDecoders exposing (routes, locationSuggestions)

import Json.Decode exposing (Decoder, maybe, int, oneOf, succeed, bool, string, float, list, object1, object2, object4, object6, object5, object7, (:=))
import API.LocationTypes exposing (LocationSuggestions, LocationSuggestion, Airport, Routes, Route)


routes : Decoder Routes
routes =
    list routeDecoder


locationSuggestions : Decoder LocationSuggestions
locationSuggestions =
    ("Places" := list suggestionDecoder)


routeDecoder : Decoder Route
routeDecoder =
    object6 Route
        ("departureDate" := string)
        ("returnDate" := string)
        ("priceCredits" := int)
        ("priceDisplay" := string)
        ("origin" := airportDecoder)
        ("destination" := airportDecoder)


airportDecoder : Decoder Airport
airportDecoder =
    object6 Airport
        ("name" := string)
        ("country" := string)
        ("cityId" := string)
        ("code" := string)
        ("latitude" := float)
        ("longitude" := float)


suggestionDecoder : Decoder LocationSuggestion
suggestionDecoder =
    object6 LocationSuggestion
        ("CityId" := string)
        ("CountryId" := string)
        ("CountryName" := string)
        ("PlaceId" := string)
        ("PlaceName" := string)
        (oneOf [ "RegionId" := string, succeed "" ])
