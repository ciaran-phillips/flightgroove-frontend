module Messages exposing (..)

import UIComponents.Menu as Menu
import UIComponents.Map.Map as Map
import UIComponents.Filters as Filters


type Msg
    = MenuMsg Menu.Msg
    | MapMsg Map.Msg
    | FilterMsg Filters.Msg


type Route
    = RouteOne
    | RouteTwo
