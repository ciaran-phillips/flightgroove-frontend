module UIComponents.Map.Sidebar.SidebarMessages exposing (..)

import API.Response as Response
import Http


-- Custom Modules

import UIComponents.Map.Sidebar.SidebarModel as SidebarModel


type SidebarMsg
    = SelectTab Int
    | MoveGrid MoveGridMsg
    | GridFetchSuccess Response.Response
    | GridFetchFail Http.Error
    | SelectGridItem SidebarModel.CellData
    | ShowFlights FlightSearchConfig


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
