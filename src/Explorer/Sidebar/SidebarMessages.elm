module Explorer.Sidebar.SidebarMessages exposing (..)

import API.Response as Response
import Http
import API.CostOfLiving as COL
import API.Activities as Activities


-- Custom Modules

import Explorer.Sidebar.SidebarModel as SidebarModel


type SidebarMsg
    = SelectTab Int
    | MoveGrid MoveGridMsg
    | GridFetchSuccess Response.Response
    | GridFetchFail Http.Error
    | SelectGridItem SidebarModel.CellData
    | ShowFlights FlightSearchConfig
    | CloseSidebar
    | OpenSidebar
    | CostOfLivingFetchSuccess COL.CostOfLiving
    | CostOfLivingFetchFailure Http.Error
    | ActivitiesFetchSuccess Activities.Activities
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
