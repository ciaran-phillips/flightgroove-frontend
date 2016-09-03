module API.ResponseDecoder exposing (..)

import Json.Decode exposing (Decoder, int, string, float, list, object1, object6, object5, object7, (:=))
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
        ("cityId" := string)
        ("countryId" := string)
        ("countryName" := string)
        ("placeId" := string)
        ("placeName" := string)
        ("regionId" := string)


locationsDecoder : Decoder Response.Response
locationsDecoder =
    object1 Response.LocationsResponse <|
        ("Place" := list suggestionDecoder)
