module API.Skyscanner exposing (..)

-- Core Imports

import Http
import Task


-- Custom Imports

import API.ResponseDecoder as ResponseDecoder
import API.Response exposing (RoutesResponse)


-- Module constants


baseUrl : String
baseUrl =
    "http://localhost:4000/mockapi/"



-- Module types


type Service
    = BrowseRoutes
    | BrowseDates


type alias APIRequest =
    { service : Service
    , origin : String
    , numberPeople : Int
    , roundTrip : Bool
    , month : String
    }


callApi : Task.Task Http.Error RoutesResponse
callApi =
    sendRequest "http://localhost:4000/mockapi/city-to-anywhere.json"


sendRequest : String -> Task.Task Http.Error RoutesResponse
sendRequest url =
    Http.get ResponseDecoder.getDecoder url


urlConstructor : APIRequest -> String
urlConstructor request =
    baseUrl
        ++ serviceToEndpoint request.service
        ++ buildArgs request


buildArgs : APIRequest -> String
buildArgs request =
    "origin="
        ++ request.origin
        ++ "&number="
        ++ toString request.numberPeople
        ++ "&roundTrip="
        ++ toString request.roundTrip
        ++ "&month"
        ++ request.month


serviceToEndpoint : Service -> String
serviceToEndpoint service =
    case service of
        BrowseRoutes ->
            "city-to-anywhere.json"

        BrowseDates ->
            "browsedates"
