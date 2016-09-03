module API.Skyscanner exposing (..)

-- Core Imports

import Http
import Task
import Json.Decode exposing (Decoder)


-- Custom Imports

import API.ResponseDecoder as ResponseDecoder
import API.Response as Response


-- Module constants


baseUrl : String
baseUrl =
    "http://localhost:4000/"



-- Module types


type Request
    = LocationsRequest LocationParams
    | BrowseRoutesRequest BrowseRouteParams


type alias LocationParams =
    { query : String }


type alias BrowseRouteParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


callRoutes : BrowseRouteParams -> Task.Task Http.Error Response.Routes
callRoutes request =
    callApi ResponseDecoder.routesDecoder <| BrowseRoutesRequest request


callLocations : LocationParams -> Task.Task Http.Error Response.Locations
callLocations request =
    callApi ResponseDecoder.locationsDecoder <| LocationsRequest request


callApi : Request -> Task.Task Http.Error response
callApi request =
    sendRequest request


sendRequest : Request -> Decoder response -> Task.Task Http.Error response
sendRequest decoder request =
    Http.get
        decoder
        (urlConstructor request)


urlConstructor : Request -> String
urlConstructor request =
    baseUrl
        ++ buildArgs request


buildArgs : Request -> String
buildArgs request =
    case request of
        LocationsRequest params ->
            "origin/" ++ params.query

        BrowseRoutesRequest params ->
            "routes/"
                ++ params.origin
                ++ "/"
                ++ params.destination
                ++ "/"
                ++ params.outboundDate
                ++ "/"
                ++ params.inboundDate
