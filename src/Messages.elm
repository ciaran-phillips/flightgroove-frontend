module Messages exposing (..)

import UIComponents.Map.Map as Map
import UIComponents.Map.Filters.Filters as Filters


type Msg
    = MapMsg Map.Msg
    | FilterMsg Filters.Msg


type Route
    = RouteOne
    | RouteTwo
