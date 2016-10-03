module UIComponents.Map.Update exposing (update)

import UIComponents.Types exposing (RemoteData(..))
import UIComponents.Map.Messages exposing (..)
import UIComponents.Map.Model as Model exposing (Model)
import UIComponents.Map.Types exposing (..)
import UIComponents.Map.Ports as Ports
import UIComponents.Map.Commands as Commands
import UIComponents.Map.Sidebar.SidebarUpdate as SidebarUpdate
import UIComponents.Map.Sidebar.SidebarCommands as SidebarCommands
import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Map.Sidebar.SidebarMessages exposing (..)
import UIComponents.Map.FlightSearch.FlightSearchModel as FlightSearchModel
import UIComponents.Map.FlightSearch.FlightSearchMessages exposing (..)
import UIComponents.Map.FlightSearch.FlightSearchCommands as FlightSearchCommands
import API.PollLivePricing as PollLivePricing
import API.Response as Response
import Material
import Process


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MDL Boilerplate
        Mdl msg' ->
            Material.update msg' model

        MapResponse response ->
            ( { model | mapActive = response }, Cmd.none )

        PopupResponse response ->
            ( model, Cmd.none )

        SelectDestination dest ->
            let
                x =
                    Debug.log ("setting destination to " ++ dest) <| Just dest
            in
                ( { model | selectedDestination = x, sidebar = Just (newSidebar dest model) }
                , SidebarCommands.getFullMonthData model
                )

        ChangeCriteria newCriteria ->
            if newCriteria == model.criteria then
                ( model, Cmd.none )
            else
                ( { model | criteria = newCriteria }
                , Commands.getApiData newCriteria
                )

        FetchData ->
            ( model, Commands.getApiData model.criteria )

        FetchFail error ->
            let
                r =
                    Debug.log "error is: " error
            in
                ( always model r, Cmd.none )

        FetchSuccess response ->
            case response of
                Response.RoutesResponse routes ->
                    ( { model | mapData = routes }, Commands.createPopups routes )

                Response.DateGridResponse result ->
                    model ! []

                Response.LocationsResponse locations ->
                    model ! []

        SidebarTag (ShowFlights config) ->
            let
                ( flightSearchModel, flightSearchCmd ) =
                    newLiveFlightSearch model config
            in
                { model | flightSearch = Just flightSearchModel } ! [ flightSearchCmd ]

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

        FlightSearchTag msg ->
            case model.flightSearch of
                Nothing ->
                    model ! []

                Just flightSearch ->
                    let
                        ( updatedFlightSearch, newCmd ) =
                            updateFlightSearch flightSearch msg
                    in
                        ( { model | flightSearch = Just updatedFlightSearch }, newCmd )


updateFlightSearch : FlightSearchModel.FlightSearchModel -> FlightSearchMsg -> ( FlightSearchModel.FlightSearchModel, Cmd Msg )
updateFlightSearch model msg =
    case msg of
        StartLivePricingSuccess response ->
            let
                newModel =
                    { model | pollingUrl = Just response.location }
            in
                ( newModel, FlightSearchCommands.pollPrices newModel )

        StartLivePricingFailure err ->
            ( always model <| Debug.log "Start pricing error is " err, Cmd.none )

        PollLivePricingSuccess response ->
            let
                newModel =
                    { model | pollingFinished = Debug.log "response completed: " response.completed, flights = Just <| Debug.log "response is: " response }
            in
                ( newModel, FlightSearchCommands.pollPrices <| Debug.log "polling " newModel )

        PollLivePricingFailure err ->
            ( always model <| Debug.log "Polling error is " err, Cmd.none )


updateSidebar : SidebarModel.SidebarModel -> SidebarMsg -> ( SidebarModel.SidebarModel, Cmd Msg )
updateSidebar sidebarModel msg =
    case msg of
        MoveGrid msg ->
            { sidebarModel | gridPosition = SidebarUpdate.updateGridPosition msg sidebarModel } ! []

        SelectTab tab ->
            { sidebarModel | activeTab = tab } ! []

        SelectGridItem cellData ->
            { sidebarModel
                | selectedOutboundDate = cellData.outboundDate
                , selectedInboundDate = cellData.inboundDate
                , gridPosition = SidebarUpdate.focusGridOn sidebarModel.gridSize cellData.x cellData.y
            }
                ! []

        GridFetchSuccess response ->
            case response of
                Response.DateGridResponse grid ->
                    { sidebarModel
                        | dateGrid = Success grid
                        , gridSize = SidebarModel.getGridSize grid
                    }
                        ! []

                Response.RoutesResponse routes ->
                    sidebarModel ! []

                Response.LocationsResponse locations ->
                    sidebarModel ! []

        GridFetchFail err ->
            sidebarModel ! []

        ShowFlights config ->
            sidebarModel ! []


{-| Create a new sidebar model for the given destination
-}
newSidebar : String -> Model -> SidebarModel.SidebarModel
newSidebar dest model =
    let
        cheapestRoute =
            Response.getCheapestRouteForDestination model.mapData dest
    in
        case cheapestRoute of
            Nothing ->
                Debug.crash "no cheapest route!!"

            Just route ->
                SidebarModel.newSidebarModel dest route.departureDate route.returnDate route.priceDisplay


newLiveFlightSearch : Model -> FlightSearchConfig -> ( FlightSearchModel.FlightSearchModel, Cmd Msg )
newLiveFlightSearch model config =
    FlightSearchModel.init <|
        FlightSearchModel.InitialFlightCriteria
            model.criteria.locationId
            config.destination
            config.outboundDate
            config.inboundDate
