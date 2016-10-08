module API.Activities exposing (..)

import Json.Decode as Decode exposing ((:=), object3, object7, string, list)
import Task
import Http


type alias Params =
    { locationQuery : String }


type alias Activities =
    { destination : String
    , fullName : String
    , activities : List Activity
    }


type alias Activity =
    { title : String
    , fromPrice : String
    , fromPriceLabel : String
    , id : String
    , imageUrl : String
    , supplierName : String
    , duration : String
    }


getData : Params -> Task.Task Http.Error Activities
getData params =
    Http.get decoder <|
        buildUrl params


buildUrl : Params -> String
buildUrl params =
    "http://localhost:4000/activities/"
        ++ (Http.uriEncode params.locationQuery)


decoder : Decode.Decoder Activities
decoder =
    object3 Activities
        ("destination" := string)
        ("fullName" := string)
        ("activities" := list activityDecoder)


activityDecoder : Decode.Decoder Activity
activityDecoder =
    object7 Activity
        ("title" := string)
        ("fromPrice" := string)
        ("fromPriceLabel" := string)
        ("id" := string)
        ("imageUrl" := string)
        ("supplierName" := string)
        ("duration" := string)
