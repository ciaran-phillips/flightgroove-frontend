module API.GetUserLocation.Action exposing (get)

import API.LocationTypes exposing (LocationSuggestions)
import API.LocationDecoders as Decoders
import Http
import Task


get : Task.Task Http.Error LocationSuggestions
get =
    Http.get
        Decoders.locationSuggestions
        "/api/get-user-origin/"
