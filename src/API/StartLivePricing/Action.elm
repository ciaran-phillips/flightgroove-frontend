module API.StartLivePricing exposing (..)

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


startLivePricing : StartLivePricingParams -> Task.Task Http.Error StartLivePricingResponse
startLivePricing params =
    Http.get startLivePricingDecoder <|
        buildUrl params


startLivePricingDecoder : Decode.Decoder StartLivePricingResponse
startLivePricingDecoder =
    Decode.object1 StartLivePricingResponse
        ("location" := Decode.string)


buildUrl : StartLivePricingParams -> String
buildUrl params =
    "/api/livepricing/start?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
        ++ ("&originplace=" ++ params.origin)
        ++ ("&destinationplace=" ++ params.destination)
        ++ ("&outbounddate=" ++ params.outboundDate)
        ++ ("&inbounddate=" ++ params.inboundDate)
