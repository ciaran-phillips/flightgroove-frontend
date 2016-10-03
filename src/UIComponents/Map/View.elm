module UIComponents.Map.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Model exposing (Model)
import UIComponents.Map.Sidebar.SidebarView as SidebarView
import UIComponents.Map.FlightSearch.FlightSearchView as FlightSearchView
import UIComponents.Map.FlightSearch.FlightSearchModel as FlightSearchModel
import Material


view : Model -> Html Msg
view model =
    case model.flightSearch of
        Nothing ->
            div [] [ viewMap model ]

        Just flightSearchModel ->
            div []
                [ viewMap model
                , viewFlightSearch model.mdl flightSearchModel
                ]


viewFlightSearch : Material.Model -> FlightSearchModel.FlightSearchModel -> Html Msg
viewFlightSearch mdl model =
    FlightSearchView.view mdl model


viewMap : Model -> Html Msg
viewMap model =
    let
        sidebar =
            case model.sidebar of
                Nothing ->
                    text ""

                Just sidebarModel ->
                    SidebarView.view model.mdl sidebarModel
    in
        div [ class "map-wrapper" ]
            [ sidebar
            , div [ id mapId ] []
            ]


mapId : String
mapId =
    "map"
