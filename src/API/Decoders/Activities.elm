module API.Decoders.Activities exposing (activities)

import Json.Decode as Decode exposing (field, map3, map7, string, list)
import API.Types.Activities as Types


activities : Decode.Decoder Types.Activities
activities =
    map3 Types.Activities
        (field "destination" string)
        (field "fullName" string)
        (field "activities" (list activityDecoder))


activityDecoder : Decode.Decoder Types.Activity
activityDecoder =
    map7 Types.Activity
        (field "title" string)
        (field "fromPrice" string)
        (field "fromPriceLabel" string)
        (field "id" string)
        (field "imageUrl" string)
        (field "supplierName" string)
        (field "duration" string)
