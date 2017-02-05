module Model exposing (..)

import UIComponents.Map.Map as Map
import UIComponents.Map.Filters.Filters as Filters


type alias Model =
    { route : String
    , mapModel : Map.Model
    , filtersModel : Filters.Model
    }
