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
import API.Response as Response
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
