module API.GetRoutesMultipleOrigins.Action exposing (Params, get)

import Task
import Http
import API.LocationTypes as LocationTypes
import API.LocationDecoders as Decoders
import Json.Decode as Decode


type alias Params =
    { origin : String
    , secondOrigin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


get : Params -> Task.Task Http.Error LocationTypes.Routes
get params =
    Http.get Decoders.routes <|
        buildUrl params


buildUrl : Params -> String
buildUrl params =
    "/api/routes-multiple-origins/"
        ++ (Http.uriEncode params.origin ++ "/")
        ++ (Http.uriEncode params.secondOrigin ++ "/")
        ++ (Http.uriEncode params.destination ++ "/")
        ++ (Http.uriEncode params.outboundDate ++ "/")
        ++ (Http.uriEncode params.inboundDate ++ "/")
