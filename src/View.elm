module View exposing (..)


-- Core and Third Party Modules
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Html.Events exposing (onClick)


-- Custom Modules
import Messages exposing (Msg(..))
import Model exposing (Model)
import UIComponents.Lib.Dropdown as Dropdown


view : Model -> Html Msg
view model =
  basePage model


basePage : Model -> Html Msg
basePage model =
  div [ class "wrapper" ]
    [ h1 [] [ text model.route ]
    , div [ class "container-fluid" ]
      [ div [ class "row header" ] topBarRows
      , div [ class "row filterbar" ] <| filterRows model
      , div [ class "row" ] [ mapContainer ]
      ]
    ]


topBarRows : List (Html Msg)
topBarRows =
  [ div [ class "col-xs-3 logo-holder" ] [ text "your trip, your way" ]
  , div [ class "col-xs-3" ] [ searchBox ]
  , div [ class "col-xs-3" ] []
  , div [ class "col-xs-3" ] []
  ]


filterRows : Model -> List (Html Msg)
filterRows model =
  [ div [ class "col-xs-3" ] []
  , div [ class "col-xs-2" ] [ dropdownLinks model ]
  , div [ class "col-xs-2" ] [ text "stopovers" ]
  , div [ class "col-xs-2" ] [ text "pricing" ]
  ]


dropdownLinks : Model -> Html Msg
dropdownLinks model =
  let
    listOfLinks =
      [ li [] [ a [ href "#", onClick (Dropdown.Navigate Messages.RouteOne) ] [ text "Filter 1"] ]
      , li [] [ a [ href "#", onClick (Dropdown.Navigate Messages.RouteTwo) ] [ text "Filter 2"] ]
      , li [] [ a [ href "#", onClick (Dropdown.Navigate Messages.RouteTwo) ] [ text "Filter 3"] ]
      ]
  in
    Html.App.map DropdownMsg
      <| Dropdown.view listOfLinks model.dropdownModel


searchBox : Html Msg
searchBox =
  filterWrapper "flying from"
    <| input [ placeholder "Dublin, Ireland (DUB)", class "form-control" ] []


filterWrapper : String -> Html Msg -> Html Msg
filterWrapper labelText filterHtml =
  div [ class "form-group filter"]
    [ label [] [ text labelText]
    , div [] [ filterHtml ]
    ]


mapContainer : Html Msg
mapContainer =
  div [] []
