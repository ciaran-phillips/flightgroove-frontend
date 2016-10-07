module API.CostOfLiving exposing (..)

import API.CostOfLivingDecoder as CostOfLivingDecoder
import API.CostOfLivingTypes exposing (..)


getData : Params -> Task.Task Http.Error CostOfLiving
getData params =
    Http.get CostOfLivingDecoder.decoder <|
        buildUrl params


buildUrl : Params -> String
buildUrl params =
    "http://localhost:4000/costofliving/"
        ++ params.cityId
