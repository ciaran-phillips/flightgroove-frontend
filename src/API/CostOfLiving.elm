module API.CostOfLiving exposing (..)

import API.CostOfLivingDecoder as CostOfLivingDecoder
import API.CostOfLivingTypes as Types
import Http
import Task


type alias CostOfLiving =
    Types.CostOfLiving


getData : Types.Params -> Task.Task Http.Error CostOfLiving
getData params =
    Http.get CostOfLivingDecoder.decoder <|
        buildUrl params


buildUrl : Types.Params -> String
buildUrl params =
    "/api/costofliving/"
        ++ params.cityId
