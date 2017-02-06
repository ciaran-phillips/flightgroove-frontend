module API.GetActivities.Action exposing (..)

import Task
import Http
import API.GetActivities.Decoder as Decoder
import API.GetActivities.Types as Types


get : Types.Params -> Task.Task Http.Error Types.Activities
get params =
    Http.get Decoder.decoder <|
        buildUrl params


buildUrl : Types.Params -> String
buildUrl params =
    "/api/activities/"
        ++ (Http.uriEncode params.locationQuery)
