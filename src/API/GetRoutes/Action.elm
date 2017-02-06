module API.GetRoutes.Action exposing (..)

import Http
import Task
import Json.Decode exposing (Decoder, maybe, int, oneOf, succeed, bool, string, float, list, object1, object2, object4, object6, object5, object7, (:=))
import API.LocationTypes exposing (Routes, Route, Airport)
import API.LocationDecoders as Decoders


type alias BrowseRouteParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


get : BrowseRouteParams -> Task.Task Http.Error Routes
get request =
    Http.get Decoders.routes <| buildUrl request


buildUrl : BrowseRouteParams -> String
buildUrl params =
    "api/routes/"
        ++ params.origin
        ++ "/"
        ++ params.destination
        ++ "/"
        ++ params.outboundDate
        ++ "/"
        ++ params.inboundDate


getRoutesForLocation : Routes -> String -> Routes
getRoutesForLocation routes locationId =
    let
        filterFunc =
            \n -> n.destination.airportCode == locationId
    in
        List.filter filterFunc routes


getCheapestRouteForDestination : Routes -> String -> Maybe Route
getCheapestRouteForDestination routes destination =
    getRoutesForLocation routes destination
        |> List.sortBy .priceCredits
        |> List.head
