module UIComponents.Map.Messages exposing (Msg(..))

import API.Response as Response
import Http
import UIComponents.Types exposing (FilterCriteria)
import Material


type Msg
    = MapResponse Bool
    | PopupResponse Bool
    | FetchData
    | FetchSuccess Response.Response
    | FetchFail Http.Error
    | ChangeCriteria FilterCriteria
    | SelectDestination String
    | SelectTab Int
    | Mdl (Material.Msg Msg)
