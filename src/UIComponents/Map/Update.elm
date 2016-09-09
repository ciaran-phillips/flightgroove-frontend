module UIComponents.Map.Update exposing (update)

import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Model exposing (Model)
import UIComponents.Types exposing (FilterCriteria)
import UIComponents.Map.Ports as Ports
import API.Response as Response
import API.Skyscanner as API
import Http
import Task
import String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MapResponse response ->
            ( { model | mapActive = response }, Cmd.none )

        PopupResponse response ->
            let
                x =
                    Debug.log "successfully added popup" response
            in
                ( model, Cmd.none )

        SelectDestination dest ->
            let
                x =
                    Debug.log ("setting destination to " ++ dest) <| Just dest
            in
                ( { model | selectedDestination = x }, Cmd.none )

        ChangeCriteria newCriteria ->
            if newCriteria == model.criteria then
                ( model, Cmd.none )
            else
                ( { model | criteria = newCriteria }, getApiData newCriteria )

        FetchData ->
            ( model, getApiData model.criteria )

        FetchFail error ->
            ( model, Cmd.none )

        FetchSuccess response ->
            case response of
                Response.RoutesResponse routes ->
                    ( { model | mapData = routes }, createPopups routes )

                Response.LocationsResponse locations ->
                    ( model, Cmd.none )


getApiData : FilterCriteria -> Cmd Msg
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


getRoutes : FilterCriteria -> Task.Task Http.Error Response.Response
getRoutes criteria =
    API.callRoutes
        { origin = criteria.locationId
        , destination = "anywhere"
        , outboundDate = criteria.outboundDate
        , inboundDate = criteria.inboundDate
        }
