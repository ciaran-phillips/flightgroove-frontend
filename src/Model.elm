module Model exposing (..)

import Explorer.Model as ExplorerModel
import Explorer.Filters.Filters as Filters


type alias Model =
    { route : String
    , mapModel : ExplorerModel.Model
    , filtersModel : Filters.Model
    , filterDrawerOpen : Bool
    }
