module Main exposing (..)


-- Core and Third party packages
import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App

-- Custom Packages
import View exposing (view)
import Messages exposing (Msg(..), Route(..))
import Model exposing (Model)
import UIComponents.Lib.Dropdown as Dropdown
import UIComponents.Menu as Menu


init : ( Model, Cmd Msg)
init =
  ( { dropdownModel = Dropdown.initialModel, route = "" }, Cmd.none)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  case message of
    DropdownMsg (Dropdown.Navigate routeMsg) ->
      let
        ( newModel, newCmd ) =
          Dropdown.update (Dropdown.Navigate routeMsg) model.dropdownModel
        newRoute = getRouteFromMessage routeMsg
      in
        ( { model | dropdownModel = newModel, route = newRoute}, Cmd.map DropdownMsg newCmd )
    DropdownMsg msg ->
      let
        ( newModel, newCmd ) =
          Dropdown.update msg model.dropdownModel
      in
        ( { model | dropdownModel = newModel}, Cmd.map DropdownMsg newCmd )


getRouteFromMessage : Route -> String
getRouteFromMessage route =
  case route of
    RouteOne ->
      "Route One"
    RouteTwo ->
      "Route Two"

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
