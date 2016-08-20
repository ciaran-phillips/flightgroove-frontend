module Messages exposing (..)

import UIComponents.Menu as Menu
import UIComponents.Map as Map


type Msg
    = MenuMsg Menu.Msg
    | MapMsg Map.Msg


type Route
    = RouteOne
    | RouteTwo
