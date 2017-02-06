module API.GetDateGrid.Action exposing (..)

import Http
import Task
import API.DateGridTypes exposing (DateGrid)
import API.DateGridDecoders as Decoders


type alias DateGridParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


get : DateGridParams -> Task.Task Http.Error DateGrid
get request =
    Http.get Decoders.dateGrid <|
        dateGridUrl request


dateGridUrl : DateGridParams -> String
dateGridUrl params =
    "api/dategrid/"
        ++ params.origin
        ++ "/"
        ++ params.destination
        ++ "/"
        ++ params.outboundDate
        ++ "/"
        ++ params.inboundDate
