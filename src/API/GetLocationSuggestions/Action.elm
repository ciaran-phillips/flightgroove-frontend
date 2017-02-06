module API.GetLocationSuggestions.Action exposing (..)

import Http
import Task
import Json.Decode exposing (Decoder, object6, string, list, oneOf, succeed)
import API.LocationTypes exposing (LocationSuggestion, LocationSuggestions)
import API.LocationDecoders as Decoders


type alias LocationParams =
    { query : String }


get : LocationParams -> Task.Task Http.Error LocationSuggestions
get params =
    Http.get
        Decoders.locationSuggestions
    <|
        "api/origin/"
            ++ params.query
