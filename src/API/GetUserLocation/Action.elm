module API.GetUserLocation.Action exposing (get)

import API.Response as Response
import API.ResponseDecoder exposing (locationsDecoder)
import Http
import Task


get : Task.Task Http.Error Response.Response
get =
    Http.get
        locationsDecoder
        "/api/get-user-origin/"
