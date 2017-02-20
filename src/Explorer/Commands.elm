module Explorer.Commands exposing (..)

import Explorer.Filters.Types as FiltersTypes
import Explorer.Ports as Ports
import Explorer.Messages exposing (..)
import API.Types.Location as LocationTypes
import API.Calls as API
import Http
import Task
import String


initialCmd : Cmd Msg
initialCmd =
    Ports.map
        "map"


getApiData : FiltersTypes.FilterCriteria -> Cmd Msg
getApiData criteria =
    Http.send UpdateRoutes <|
        if String.isEmpty criteria.locationId then
            getRoutes criteria
        else
            getRoutes criteria


createPopups : LocationTypes.Routes -> Cmd Msg
createPopups routes =
    List.map popupFromRoute routes
        |> Cmd.batch


popupFromRoute : LocationTypes.Route -> Cmd msg
popupFromRoute route =
    Ports.popup
        ( route.destination.airportCode
        , route.destination.longitude
        , route.destination.latitude
        , route.priceDisplay
        )


getRoutes : FiltersTypes.FilterCriteria -> Http.Request LocationTypes.Routes
getRoutes criteria =
    case criteria.secondOriginId of
        Nothing ->
            API.getRoutes
                { origin = criteria.locationId
                , destination = "anywhere"
                , outboundDate = criteria.outboundDate
                , inboundDate = criteria.inboundDate
                }

        Just originId ->
            API.getRoutesMultipleOrigins
                { origin = criteria.locationId
                , secondOrigin = originId
                , destination = "anywhere"
                , outboundDate = criteria.outboundDate
                , inboundDate = criteria.inboundDate
                }
