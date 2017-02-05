module Explorer.Messages exposing (..)

import API.Response as Response
import Http
import Explorer.Filters.Types exposing (FilterCriteria)
import Material
import Explorer.Sidebar.SidebarMessages exposing (SidebarMsg)
import Explorer.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg)
import Explorer.MapComp.MapMessages exposing (MapMsg)


type Msg
    = FetchSuccess Response.Response
    | FetchFail Http.Error
    | ChangeCriteria FilterCriteria
    | Mdl (Material.Msg Msg)
    | SidebarTag SidebarMsg
    | FlightSearchTag FlightSearchMsg
    | MapTag MapMsg
