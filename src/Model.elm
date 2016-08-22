module Model exposing (..)

import UIComponents.Menu as Menu
import UIComponents.Map as Map
import UIComponents.Filters as Filters


type alias Model =
    { menuModel : Menu.Model
    , route : String
    , mapModel : Map.Model
    , filtersModel : Filters.Model
    }
