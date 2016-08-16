module Model exposing (..)

import UIComponents.Menu as Menu

type alias Model =
  { menuModel : Menu.Model, route : String }
