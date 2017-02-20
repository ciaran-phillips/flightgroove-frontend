module Explorer.Sidebar.SidebarMessages exposing (..)

import Http
import API.Types.DateGrid as DateGridTypes
import API.Types.CostOfLiving as CostOfLivingTypes
import API.Types.Activities as ActivitiesTypes


-- Custom Modules

import Explorer.Sidebar.SidebarModel as SidebarModel


type SidebarMsg
    = SelectTab Int
    | MoveGrid MoveGridMsg
    | GridFetchUpdate (Result Http.Error DateGridTypes.DateGrid)
    | SelectGridItem SidebarModel.CellData
    | ShowFlights FlightSearchConfig
    | CloseSidebar
    | OpenSidebar
    | CostOfLivingFetchUpdate (Result Http.Error CostOfLivingTypes.CostOfLiving)
    | ActivitiesFetchUpdate (Result Http.Error ActivitiesTypes.Activities)


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
