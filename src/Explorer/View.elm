module Explorer.View exposing (viewFlightMap, viewMenu)

import Html exposing (..)
import Html.Attributes exposing (id, class, classList, src, href, target)
import Html.App
import Explorer.Types exposing (RemoteData(..))
import Explorer.Messages exposing (Msg(..))
import Explorer.Model exposing (Model)
import Explorer.Sidebar.SidebarView as SidebarView
import Explorer.FlightSearch.FlightSearchView as FlightSearchView
import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel
import Explorer.Filters.Filters as Filters
import Material
import Material.Spinner as Loading
import Material.Options as Options


viewFlightMap : Model -> Html Msg
viewFlightMap model =
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
            , div [ id "map" ] []
            ]


skyscannerLogo : Html Msg
skyscannerLogo =
    a [ target "_blank", href "https://skyscanner.net" ] [ img [ src "/assets/img/skyscanner-logo.png", class "skyscanner-logo" ] [] ]


viewMenu : Model -> Html Msg
viewMenu model =
    div [ class "mdl-grid" ]
        [ div [ class "mdl-cell mdl-cell--2-col filter-bar__logo" ]
            [ div [ class "logo--part" ] [ img [ src "assets/img/logo.png" ] [] ]
            , div [ class "logo--part" ]
                [ div [ class "logo--heading" ] [ text "flightgroove" ]
                , div [ class "logo--tagline" ] [ text "your trip, your way" ]
                ]
            ]
        , div [ class "mdl-cell mdl-cell--3-col-desktop mdl-cell--6-col-tablet" ] [ searchBox model ]
        , div [ class "mdl-cell mdl-cell--4-col-desktop mdl-cell--6-col-tablet" ]
            [ label [] [ text "departure / return dates" ]
            , div [ class "date-inputs form-control" ]
                [ outboundDate model
                , inboundDate model
                ]
            ]
        , div [ class "mdl-cell mdl-cell--3-col-desktop mdl-cell--6-col-tablet" ] [ dateToggle model, originsToggle model ]
        ]


searchBox : Model -> Html Msg
searchBox model =
    Html.App.map FilterTag <|
        Filters.viewOriginSearch model.filtersModel


outboundDate : Model -> Html Msg
outboundDate model =
    Html.App.map FilterTag <|
        Filters.viewOutboundDate model.filtersModel


inboundDate : Model -> Html Msg
inboundDate model =
    Html.App.map FilterTag <|
        Filters.viewInboundDate model.filtersModel


dateToggle : Model -> Html Msg
dateToggle model =
    Html.App.map FilterTag <|
        Filters.viewToggle model.filtersModel


originsToggle : Model -> Html Msg
originsToggle model =
    Html.App.map FilterTag <|
        Filters.viewOriginsToggle model.filtersModel


filterWrapper : String -> Html Msg -> Html Msg
filterWrapper labelText filterHtml =
    div [ class "form-group form-control filter" ]
        [ label [] [ text labelText ]
        , div [] [ filterHtml ]
        ]
