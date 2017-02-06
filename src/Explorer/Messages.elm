module Explorer.Messages exposing (..)

import Http
import Explorer.Filters.Types exposing (FilterCriteria)
import Material
import Explorer.Sidebar.SidebarMessages exposing (SidebarMsg)
import Explorer.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg)
import Explorer.MapComp.MapMessages exposing (MapMsg)
import API.LocationTypes as LocationTypes


type Msg
    = GetRoutesSuccess LocationTypes.Routes
    | GetRoutesFailure Http.Error
    | ChangeCriteria FilterCriteria
    | Mdl (Material.Msg Msg)
    | SidebarTag SidebarMsg
    | FlightSearchTag FlightSearchMsg
    | MapTag MapMsg
