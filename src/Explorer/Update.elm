module Explorer.Update exposing (update)

import Explorer.Types exposing (RemoteData(..))
import Explorer.Messages exposing (..)
import Explorer.Model as Model exposing (Model)
import Explorer.Ports as Ports
import Explorer.Commands as Commands
import Explorer.Sidebar.SidebarUpdate as SidebarUpdate
import Explorer.Sidebar.SidebarCommands as SidebarCommands
import Explorer.Sidebar.SidebarModel as SidebarModel
import Explorer.Sidebar.SidebarMessages exposing (..)
import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel exposing (FlightsForOrigin(..))
import Explorer.FlightSearch.FlightSearchMessages exposing (..)
import Explorer.FlightSearch.FlightSearchCommands as FlightSearchCommands
import Explorer.FlightSearch.FlightSearchUpdate as FlightSearchUpdate
import Explorer.Map.MapMessages exposing (..)
import Explorer.Filters.Filters as Filters
import API.Calls as API
import API.Types.Location as LocationTypes
import Material
import Process
import Dict


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MDL Boilerplate
        Mdl msg' ->
            Material.update msg' model

        FilterTag msg ->
            let
                ( newFiltersModel, newFiltersCmd ) =
                    Filters.update msg model.filtersModel

                filterCriteria =
                    Filters.getCriteria newFiltersModel

                criteriaChangedCmd =
                    if filterCriteria == model.criteria then
                        Cmd.none
                    else
                        Cmd.batch
                            [ Ports.clearPopups True
                            , Commands.getApiData filterCriteria
                            ]
            in
                ( { model | filtersModel = newFiltersModel, criteria = filterCriteria }
                , Cmd.batch [ Cmd.map FilterTag newFiltersCmd, criteriaChangedCmd ]
                )

        ChangeCriteria newCriteria ->
            if newCriteria == model.criteria then
                ( model, Cmd.none )
            else
                ( { model
                    | criteria = newCriteria
                    , mapData = Loading
                  }
                , Cmd.batch
                    [ Ports.clearPopups True
                    , Commands.getApiData newCriteria
                    ]
                )

        GetRoutesFailure error ->
            let
                model' =
                    always model <| Debug.log "error is: " error
            in
                ( { model' | mapData = Failure error }, Cmd.none )

        GetRoutesSuccess routes ->
            ( { model | mapData = Success routes, airports = getAirports routes }, Commands.createPopups routes )

        MapTag msg ->
            updateMap model msg

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

        FlightSearchTag CloseFlightSearch ->
            ( { model | flightSearch = Nothing }, Cmd.none )

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


updateMap : Model -> MapMsg -> ( Model, Cmd Msg )
updateMap model msg =
    case msg of
        MapResponse response ->
            ( { model | mapActive = response }, Cmd.none )

        PopupResponse response ->
            ( model, Cmd.none )

        SelectDestination dest ->
            let
                airport =
                    Dict.get dest model.airports
            in
                case airport of
                    Nothing ->
                        model ! []

                    Just airport' ->
                        ( { model | selectedDestination = Just dest, sidebar = Just (newSidebar airport' model) }
                        , SidebarCommands.getFullMonthData model
                        )


updateFlightSearch : FlightSearchModel.FlightSearchModel -> FlightSearchMsg -> ( FlightSearchModel.FlightSearchModel, Cmd Msg )
updateFlightSearch model msg =
    FlightSearchUpdate.update model msg


updateSidebar : SidebarModel.SidebarModel -> SidebarMsg -> ( SidebarModel.SidebarModel, Cmd Msg )
updateSidebar sidebarModel msg =
    case msg of
        MoveGrid msg ->
            { sidebarModel | gridPosition = SidebarUpdate.updateGridPosition msg sidebarModel } ! []

        SelectTab tab ->
            let
                ( colData, colCmd ) =
                    SidebarUpdate.getCostOfLiving sidebarModel

                ( activities, activitiesCmd ) =
                    SidebarUpdate.getActivities sidebarModel
            in
                ( { sidebarModel
                    | activeTab = tab
                    , costOfLivingData = colData
                    , activities = activities
                  }
                , Cmd.batch [ colCmd, activitiesCmd ]
                )

        SelectGridItem cellData ->
            { sidebarModel
                | selectedOutboundDate = cellData.outboundDate
                , selectedInboundDate = cellData.inboundDate
                , gridPosition = SidebarUpdate.focusGridOn sidebarModel.gridSize cellData.x cellData.y
            }
                ! []

        GridFetchSuccess grid ->
            { sidebarModel
                | dateGrid = Success grid
                , gridSize = SidebarModel.getGridSize grid
            }
                ! []

        GridFetchFail err ->
            sidebarModel ! []

        ShowFlights config ->
            sidebarModel ! []

        CloseSidebar ->
            { sidebarModel | sidebarVisible = False } ! []

        OpenSidebar ->
            { sidebarModel | sidebarVisible = True } ! []

        CostOfLivingFetchSuccess data ->
            ( { sidebarModel | costOfLivingData = Success data }, Cmd.none )

        CostOfLivingFetchFailure err ->
            ( { sidebarModel | costOfLivingData = Failure err }, Cmd.none )

        ActivitiesFetchSuccess data ->
            ( { sidebarModel | activities = Success data }, Cmd.none )

        ActivitiesFetchFailure err ->
            ( { sidebarModel | activities = Failure err }, Cmd.none )


{-| Create a new sidebar model for the given destination
-}
newSidebar : LocationTypes.Airport -> Model -> SidebarModel.SidebarModel
newSidebar destination model =
    let
        cheapestRoute =
            case model.mapData of
                Success data ->
                    LocationTypes.getCheapestRouteForDestination data destination.airportCode

                _ ->
                    Nothing

        multipleOrigins =
            case model.criteria.secondOriginId of
                Nothing ->
                    False

                Just originId ->
                    True
    in
        case cheapestRoute of
            Nothing ->
                Debug.crash "no cheapest route!!"

            Just route ->
                SidebarModel.newSidebarModel destination route.departureDate route.returnDate route.priceDisplay multipleOrigins


newLiveFlightSearch : Model -> FlightSearchConfig -> ( FlightSearchModel.FlightSearchModel, Cmd Msg )
newLiveFlightSearch model config =
    FlightSearchModel.init <|
        FlightSearchModel.InitialFlightCriteria
            model.criteria.locationId
            model.criteria.secondOriginId
            config.destination
            config.outboundDate
            config.inboundDate


getAirports : LocationTypes.Routes -> Dict.Dict String LocationTypes.Airport
getAirports routes =
    Dict.fromList <|
        List.map
            (\route -> ( route.destination.airportCode, route.destination ))
            routes
