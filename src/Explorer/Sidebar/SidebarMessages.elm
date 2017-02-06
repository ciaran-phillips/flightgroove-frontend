module Explorer.Sidebar.SidebarMessages exposing (..)

import Http
import API.GetCostOfLiving.Types as CostOfLivingTypes
import API.GetActivities.Types as ActivitiesTypes
import API.DateGridTypes as DateGridTypes


-- Custom Modules

import Explorer.Sidebar.SidebarModel as SidebarModel


type SidebarMsg
    = SelectTab Int
    | MoveGrid MoveGridMsg
    | GridFetchSuccess DateGridTypes.DateGrid
    | GridFetchFail Http.Error
    | SelectGridItem SidebarModel.CellData
    | ShowFlights FlightSearchConfig
    | CloseSidebar
    | OpenSidebar
    | CostOfLivingFetchSuccess CostOfLivingTypes.CostOfLiving
    | CostOfLivingFetchFailure Http.Error
    | ActivitiesFetchSuccess ActivitiesTypes.Activities
    | ActivitiesFetchFailure Http.Error


type MoveGridMsg
    = MoveGridUp
    | MoveGridDown
    | MoveGridLeft
    | MoveGridRight


type alias FlightSearchConfig =
    { destination : String
    , outboundDate : String
    , inboundDate : String
    }
