module API.Decoders.Location exposing (routes, locationSuggestions)

import Json.Decode exposing (Decoder, maybe, int, oneOf, succeed, bool, string, float, list, map, map2, map4, map6, map5, map7, field)
import API.Types.Location exposing (LocationSuggestions, LocationSuggestion, Airport, Routes, Route)


routes : Decoder Routes
routes =
    list routeDecoder


locationSuggestions : Decoder LocationSuggestions
locationSuggestions =
    (field "Places" (list suggestionDecoder))


routeDecoder : Decoder Route
routeDecoder =
    map7 Route
        (field "departureDate" string)
        (field "returnDate" string)
        (field "priceCredits" int)
        (field "priceDisplay" string)
        (field "origin" airportDecoder)
        (maybe (field "secondOrigin" airportDecoder))
        (field "destination" airportDecoder)


airportDecoder : Decoder Airport
airportDecoder =
    map6 Airport
        (field "name" string)
        (field "country" string)
        (field "cityId" string)
        (field "code" string)
        (field "latitude" float)
        (field "longitude" float)


suggestionDecoder : Decoder LocationSuggestion
suggestionDecoder =
    map6 LocationSuggestion
        (field "CityId" string)
        (field "CountryId" string)
        (field "CountryName" string)
        (field "PlaceId" string)
        (field "PlaceName" string)
        (field "RegionId" (oneOf [ string, succeed "" ]))
