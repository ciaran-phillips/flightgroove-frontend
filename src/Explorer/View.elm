module Explorer.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList, src, href, target)
import Explorer.Types exposing (RemoteData(..))
import Explorer.Messages exposing (Msg(..))
import Explorer.Model exposing (Model)
import Explorer.Sidebar.SidebarView as SidebarView
import Explorer.FlightSearch.FlightSearchView as FlightSearchView
import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel
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
            [ skyscannerLogo
            , sidebar
            , div [ classList [ ( "map__overlay", True ), ( "is-active", isLoading ) ] ]
                [ div [ class "background-overlay" ] []
                , Loading.spinner
                    [ Options.cs "absolute-center mdl-spinner--light-bg"
                    , Loading.active isLoading
                    , Loading.singleColor True
                    ]
                ]
            , div [ id mapId ] []
            ]


skyscannerLogo : Html Msg
skyscannerLogo =
    a [ target "_blank", href "https://skyscanner.net" ] [ img [ src "/assets/img/skyscanner-logo.png", class "skyscanner-logo" ] [] ]


mapId : String
mapId =
    "map"
