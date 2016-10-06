module UIComponents.Map.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList)
import UIComponents.Types exposing (RemoteData(..))
import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Model exposing (Model)
import UIComponents.Map.Sidebar.SidebarView as SidebarView
import UIComponents.Map.FlightSearch.FlightSearchView as FlightSearchView
import UIComponents.Map.FlightSearch.FlightSearchModel as FlightSearchModel
import Material
import Material.Spinner as Loading
import Material.Options as Options


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

        isLoading =
            case model.mapData of
                Loading ->
                    True

                _ ->
                    False
    in
        div [ class "map-wrapper" ]
            [ sidebar
            , div [ classList [ ( "map__overlay background-overlay", True ), ( "is-active", isLoading ) ] ]
                [ Loading.spinner
                    [ Options.cs "absolute-center mdl-spinner--light-bg"
                    , Loading.active isLoading
                    , Loading.singleColor True
                    ]
                ]
            , div [ id mapId ] []
            ]


mapId : String
mapId =
    "map"
