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
    "http://192.168.0.29:4000/"



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


callDates : BrowseRouteParams -> Task.Task Http.Error Response.Response
callDates request =
    Http.get ResponseDecoder.browseDatesDecoder <|
        browseDatesUrl request


browseDatesUrl : BrowseRouteParams -> String
browseDatesUrl params =
    baseUrl
        ++ "dates/"
        ++ params.origin
        ++ "/"
        ++ params.destination
        ++ "/"
        ++ params.outboundDate
        ++ "/"
        ++ params.inboundDate


callRoutes : BrowseRouteParams -> Task.Task Http.Error Response.Response
callRoutes request =
    callApi <| BrowseRoutesRequest request


callLocations : LocationParams -> Task.Task Http.Error Response.Response
callLocations request =
    callApi <| LocationsRequest request


callApi : Request -> Task.Task Http.Error Response.Response
callApi request =
    sendRequest request


sendRequest : Request -> Task.Task Http.Error Response.Response
sendRequest request =
    Http.get
        (getDecoder request)
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


getDecoder : Request -> Decoder Response.Response
getDecoder request =
    case request of
        LocationsRequest params ->
            ResponseDecoder.locationsDecoder

        BrowseRoutesRequest params ->
            ResponseDecoder.routesDecoder
