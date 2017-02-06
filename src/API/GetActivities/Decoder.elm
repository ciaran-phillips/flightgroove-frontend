module API.GetActivities.Decoder exposing (decoder)

import Json.Decode as Decode exposing ((:=), object3, object7, string, list)
import API.GetActivities.Types as Types


decoder : Decode.Decoder Types.Activities
decoder =
    object3 Types.Activities
        ("destination" := string)
        ("fullName" := string)
        ("activities" := list activityDecoder)


activityDecoder : Decode.Decoder Types.Activity
activityDecoder =
    object7 Types.Activity
        ("title" := string)
        ("fromPrice" := string)
        ("fromPriceLabel" := string)
        ("id" := string)
        ("imageUrl" := string)
        ("supplierName" := string)
        ("duration" := string)
