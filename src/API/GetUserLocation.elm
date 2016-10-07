module API.GetUserLocation exposing (..)

import API.Response as Response
import API.ResponseDecoder exposing (locationsDecoder)
import Http
import Task


getUserLocation : Task.Task Http.Error Response.Response
getUserLocation =
    Http.get
        locationsDecoder
        "http://localhost:4000/get-user-origin/"
