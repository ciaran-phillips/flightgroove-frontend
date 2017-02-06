module API.GetCostOfLiving.Action exposing (..)

import API.GetCostOfLiving.Decoder as Decoder
import API.GetCostOfLiving.Types as Types
import Http
import Task


type alias CostOfLiving =
    Types.CostOfLiving


get : Types.Params -> Task.Task Http.Error CostOfLiving
get params =
    Http.get Decoder.decoder <|
        buildUrl params


buildUrl : Types.Params -> String
buildUrl params =
    "/api/costofliving/"
        ++ params.cityId
