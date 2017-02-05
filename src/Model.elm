module Model exposing (..)

import UIComponents.Map.Map as Map
import UIComponents.Filters as Filters


type alias Model =
    { route : String
    , mapModel : Map.Model
    , filtersModel : Filters.Model
    }
