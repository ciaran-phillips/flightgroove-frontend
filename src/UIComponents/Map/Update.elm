module UIComponents.Map.Update exposing (update)

import UIComponents.Map.Messages exposing (Msg(..), GridMsg)
import UIComponents.Map.Model as Model exposing (Model, SidebarModel)
import UIComponents.Map.Types exposing (..)
import UIComponents.Types exposing (FilterCriteria)
import UIComponents.Map.Ports as Ports
import UIComponents.Map.Sidebar as Sidebar
import API.Response as Response
import API.Skyscanner as API
import Http
import Task
import String
import Material


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MDL Boilerplate
        Mdl msg' ->
            Material.update msg' model

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
                ( { model | selectedDestination = x, sidebar = Just (newSidebar dest model) }, getFullMonthData model )

        ChangeCriteria newCriteria ->
            if newCriteria == model.criteria then
                ( model, Cmd.none )
            else
                ( { model | criteria = newCriteria }, getApiData newCriteria )

        FetchData ->
            ( model, getApiData model.criteria )

        FetchFail error ->
            let
                r =
                    Debug.log "error is: " error
            in
                ( always model r, Cmd.none )

        FetchSuccess response ->
            case response of
                Response.RoutesResponse routes ->
                    ( { model | mapData = routes }, createPopups routes )

                Response.DateGridResponse result ->
                    ( { model | sidebar = updateSidebarGrid model.sidebar result }
                    , Cmd.none
                    )

                Response.LocationsResponse locations ->
                    ( model, Cmd.none )

        SelectTab tab ->
            { model | sidebar = updateSidebarTab model.sidebar tab } ! []

        MoveGrid msg ->
            let
                updatedSidebar =
                    updateGridPosition msg model.sidebar
            in
                { model | sidebar = updatedSidebar } ! []

        SelectGridItem ( outbound, inbound ) ->
            case model.sidebar of
                Nothing ->
                    model ! []

                Just sidebar ->
                    { model | sidebar = Just { sidebar | selectedOutboundDate = outbound, selectedInboundDate = inbound } } ! []


updateSidebarGrid : Maybe SidebarModel -> Response.DateGrid -> Maybe SidebarModel
updateSidebarGrid sidebar grid =
    case sidebar of
        Nothing ->
            Nothing

        Just sidebarModel ->
            Just { sidebarModel | dateGrid = Success grid, gridSize = Model.getGridSize grid }


updateSidebarTab : Maybe SidebarModel -> Int -> Maybe SidebarModel
updateSidebarTab sidebar tab =
    case sidebar of
        Nothing ->
            Nothing

        Just sidebarModel ->
            Just { sidebarModel | activeTab = tab }


updateGridPosition : GridMsg -> Maybe SidebarModel -> Maybe SidebarModel
updateGridPosition msg sidebar =
    case sidebar of
        Nothing ->
            Nothing

        Just sidebarModel ->
            Just { sidebarModel | gridPosition = Sidebar.updateGridPosition msg sidebarModel }


newSidebar : String -> Model -> SidebarModel
newSidebar dest model =
    let
        cheapestRoute =
            Response.getCheapestRouteForDestination model.mapData dest
    in
        case cheapestRoute of
            Nothing ->
                Debug.crash "no cheapest route!!"

            Just route ->
                Model.newSidebarModel dest route.departureDate route.returnDate route.priceDisplay


getFullMonthData : Model -> Cmd Msg
getFullMonthData model =
    let
        dest =
            case model.selectedDestination of
                Nothing ->
                    "PRG-sky"

                Just dest ->
                    dest
    in
        Task.perform FetchFail FetchSuccess <|
            API.callDates
                { origin = model.criteria.locationId
                , destination = dest
                , outboundDate = "2016-09"
                , inboundDate = "2016-09"
                }


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
