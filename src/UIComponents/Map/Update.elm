module UIComponents.Map.Update exposing (update)

import UIComponents.Map.Messages exposing (..)
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
                    model ! []

                Response.LocationsResponse locations ->
                    model ! []

        SidebarTag msg ->
            case model.sidebar of
                Nothing ->
                    model ! []

                Just sidebarModel ->
                    let
                        ( updatedSidebar, newCmd ) =
                            updateSidebar sidebarModel msg
                    in
                        ( { model | sidebar = Just updatedSidebar }, newCmd )


updateSidebar : SidebarModel -> SidebarMsg -> ( SidebarModel, Cmd Msg )
updateSidebar sidebarModel msg =
    case msg of
        MoveGrid msg ->
            { sidebarModel | gridPosition = updateGridPosition msg sidebarModel } ! []

        SelectTab tab ->
            { sidebarModel | activeTab = tab } ! []

        SelectGridItem ( outbound, inbound ) ->
            { sidebarModel | selectedOutboundDate = outbound, selectedInboundDate = inbound } ! []

        GridFetchSuccess response ->
            case response of
                Response.DateGridResponse grid ->
                    { sidebarModel | dateGrid = Success grid, gridSize = Model.getGridSize grid } ! []

                Response.RoutesResponse routes ->
                    sidebarModel ! []

                Response.LocationsResponse locations ->
                    sidebarModel ! []

        GridFetchFail err ->
            sidebarModel ! []


updateGridPosition : MoveGridMsg -> SidebarModel -> GridPosition
updateGridPosition msg sidebar =
    let
        maxPosY =
            sidebar.gridSize.rows - 6

        maxPosX =
            sidebar.gridSize.columns - 6

        position =
            sidebar.gridPosition
    in
        case msg of
            MoveGridUp ->
                { position | y = decrease 4 position.y 0 }

            MoveGridDown ->
                { position | y = increase 4 position.y maxPosY }

            MoveGridLeft ->
                { position | x = decrease 4 position.x 0 }

            MoveGridRight ->
                { position | x = increase 4 position.x maxPosX }


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
        Task.perform (SidebarTag << GridFetchFail) (SidebarTag << GridFetchSuccess) <|
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


decrease : Int -> Int -> Int -> Int
decrease stepAmount current minimum =
    if (current - stepAmount) < minimum then
        minimum
    else
        current - stepAmount


increase : Int -> Int -> Int -> Int
increase stepAmount current maximum =
    if (current + stepAmount) > maximum then
        maximum
    else
        current + stepAmount
