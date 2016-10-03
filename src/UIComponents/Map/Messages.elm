module UIComponents.Map.Messages exposing (..)

import API.Response as Response
import Http
import UIComponents.Types exposing (FilterCriteria)
import Material
import UIComponents.Map.Sidebar.SidebarMessages exposing (SidebarMsg)
import UIComponents.Map.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg)


type Msg
    = MapResponse Bool
    | PopupResponse Bool
    | FetchData
    | FetchSuccess Response.Response
    | FetchFail Http.Error
    | ChangeCriteria FilterCriteria
    | SelectDestination String
    | Mdl (Material.Msg Msg)
    | SidebarTag SidebarMsg
    | FlightSearchTag FlightSearchMsg
