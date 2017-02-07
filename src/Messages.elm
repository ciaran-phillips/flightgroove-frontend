module Messages exposing (..)

import Explorer.Map as Map
import Explorer.Filters.Filters as Filters


type Msg
    = MapMsg Map.Msg
    | FilterMsg Filters.Msg
    | ToggleFilterDrawer


type Route
    = RouteOne
    | RouteTwo
