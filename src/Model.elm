module Model exposing (..)

import UIComponents.Menu as Menu
import UIComponents.Map as Map


type alias Model =
    { menuModel : Menu.Model
    , route : String
    , mapModel : Map.Model
    }
