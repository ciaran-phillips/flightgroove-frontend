module API.ResponseDecoder exposing (..)

import Json.Decode exposing (Decoder, int, string, float, list, object6, object2, (:=))
import API.Response exposing (RoutesResponse, Destination, Location)


getDecoder : Decoder RoutesResponse
getDecoder =
    object2 RoutesResponse
        ("ageOfData" := string)
        ("destinations" := list destinationDecoder)


destinationDecoder : Decoder Destination
destinationDecoder =
    object6 Destination
        ("name" := string)
        ("country" := string)
        ("airport" := string)
        ("priceDisplay" := string)
        ("priceCredits" := int)
        ("location" := locationDecoder)


locationDecoder : Decoder Location
locationDecoder =
    object2 Location
        ("lat" := float)
        ("lon" := float)
