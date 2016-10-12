module UIComponents.Map.Commands exposing (..)

import UIComponents.Types as Types
import UIComponents.Map.Ports as Ports
import UIComponents.Map.Messages exposing (..)
import API.Response as Response
import API.Skyscanner as API
import API.RoutesForMultipleLocations as RoutesForMultipleLocations
import Http
import Task
import String


getApiData : Types.FilterCriteria -> Cmd Msg
getApiData criteria =
    Task.perform FetchFail FetchSuccess <|
        if String.isEmpty criteria.locationId then
            getRoutes criteria
        else
            getRoutes criteria


createPopups : Response.Routes -> Cmd Msg
createPopups routes =
    List.map popupFromRoute routes
        |> Cmd.batch


popupFromRoute : Response.Route -> Cmd msg
popupFromRoute route =
    Ports.popup
        ( route.destination.airportCode
        , route.destination.longitude
        , route.destination.latitude
        , route.priceDisplay
        )


getRoutes : Types.FilterCriteria -> Task.Task Http.Error Response.Response
getRoutes criteria =
    case criteria.secondOriginId of
        Nothing ->
            API.callRoutes
                { origin = criteria.locationId
                , destination = "anywhere"
                , outboundDate = criteria.outboundDate
                , inboundDate = criteria.inboundDate
                }

        Just originId ->
            RoutesForMultipleLocations.getData
                { origin = criteria.locationId
                , secondOrigin = originId
                , destination = "anywhere"
                , outboundDate = criteria.outboundDate
                , inboundDate = criteria.inboundDate
                }
