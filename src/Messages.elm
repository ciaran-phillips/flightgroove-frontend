module Messages exposing (..)

import Explorer.Messages as ExplorerMessages
import Explorer.Filters.Filters as Filters


type Msg
    = MapMsg ExplorerMessages.Msg
    | FilterMsg Filters.Msg
    | ToggleFilterDrawer


type Route
    = RouteOne
    | RouteTwo
