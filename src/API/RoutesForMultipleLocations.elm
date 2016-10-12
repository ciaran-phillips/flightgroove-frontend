module API.RoutesForMultipleLocations exposing (Params, getData)

import Task
import Http
import API.Response as Response
import API.ResponseDecoder as ResponseDecoder
import Json.Decode as Decode


type alias Params =
    { origin : String
    , secondOrigin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getData : Params -> Task.Task Http.Error Response.Response
getData params =
    Http.get decoder <|
        buildUrl params


decoder : Decode.Decoder Response.Response
decoder =
    ResponseDecoder.routesDecoder


buildUrl : Params -> String
buildUrl params =
    "/api/routes-multiple-origins/"
        ++ (Http.uriEncode params.origin ++ "/")
        ++ (Http.uriEncode params.secondOrigin ++ "/")
        ++ (Http.uriEncode params.destination ++ "/")
        ++ (Http.uriEncode params.outboundDate ++ "/")
        ++ (Http.uriEncode params.inboundDate ++ "/")
