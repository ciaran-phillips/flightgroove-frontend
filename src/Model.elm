module Model exposing (..)

import UIComponents.Lib.Dropdown as Dropdown

type alias Model =
  { dropdownModel : Dropdown.Model, route : String }
