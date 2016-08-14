module Messages exposing (..)


import UIComponents.Lib.Dropdown as Dropdown

type Msg =
  DropdownMsg (Dropdown.Msg Route)

type Route =
  RouteOne
  | RouteTwo
