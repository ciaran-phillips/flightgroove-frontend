module API.StartLivePricing.Action
    exposing
        ( StartLivePricingResponse
        , StartLivePricingParams
        , start
        )

import Json.Decode as Decode exposing ((:=))
import Http
import Task


type alias StartLivePricingResponse =
    { location : String
    }


type alias StartLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


start : StartLivePricingParams -> Task.Task Http.Error StartLivePricingResponse
start params =
    Http.get decoder <|
        buildUrl params


decoder : Decode.Decoder StartLivePricingResponse
decoder =
    Decode.object1 StartLivePricingResponse
        ("location" := Decode.string)


buildUrl : StartLivePricingParams -> String
buildUrl params =
    "/api/livepricing/start?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
        ++ ("&originplace=" ++ params.origin)
        ++ ("&destinationplace=" ++ params.destination)
        ++ ("&outbounddate=" ++ params.outboundDate)
        ++ ("&inbounddate=" ++ params.inboundDate)
