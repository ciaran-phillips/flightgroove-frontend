module API.ResponseDecoder exposing (..)

import Json.Decode exposing (Decoder, maybe, int, oneOf, succeed, bool, string, float, list, object1, object2, object4, object6, object5, object7, (:=))
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
    object6 Response.Airport
        ("name" := string)
        ("country" := string)
        ("cityId" := string)
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
        (oneOf [ "RegionId" := string, succeed "" ])


locationsDecoder : Decoder Response.Response
locationsDecoder =
    object1 Response.LocationsResponse <|
        ("Places" := list suggestionDecoder)



-- DateGrid


dateGridDecoder : Decoder Response.Response
dateGridDecoder =
    object1 Response.DateGridResponse <|
        object2 Response.DateGrid
            ("columnHeaders" := list (maybe string))
            ("rows" := list dateGridRowDecoder)


dateGridRowDecoder : Decoder Response.DateGridRow
dateGridRowDecoder =
    object2 Response.DateGridRow
        ("rowHeader" := string)
        ("cells" := list (maybe dateGridCellDecoder))


dateGridCellDecoder : Decoder Response.DateGridCell
dateGridCellDecoder =
    object4 Response.DateGridCell
        ("priceCredits" := int)
        ("priceDisplay" := string)
        ("outboundDate" := string)
        ("inboundDate" := string)
