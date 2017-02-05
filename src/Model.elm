module Model exposing (..)

import Explorer.Map as Map
import Explorer.Filters.Filters as Filters


type alias Model =
    { route : String
    , mapModel : Map.Model
    , filtersModel : Filters.Model
    }
