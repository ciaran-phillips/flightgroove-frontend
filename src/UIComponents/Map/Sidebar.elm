module UIComponents.Map.Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, src)
import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Model exposing (Model)
import API.Response as Response


-- THird party packages

import Material.Tabs as Tabs


view : Model -> Html Msg
view model =
    div [ class "sidebar" ]
        [ tabs model ]


tabs : Model -> Html Msg
tabs model =
    Tabs.render Mdl
        [ 0 ]
        model.mdl
        [ Tabs.activeTab model.activeTab
        , Tabs.onSelectTab SelectTab
        ]
        [ Tabs.textLabel [] "Flights"
        , Tabs.textLabel [] "Accommodation"
        , Tabs.textLabel [] "Cost of Living"
        , Tabs.textLabel [] "Attractions"
        ]
        [ case model.activeTab of
            0 ->
                div [ class "sidebar--block" ] <| flightsTab model

            1 ->
                div [ class "sidebar--block" ] [ text "Accommodation content" ]

            2 ->
                div [ class "sidebar--block" ] [ text "Cost of Living content" ]

            _ ->
                div [ class "sidebar--block" ] [ text "Attractions content" ]
        ]


flightsTab : Model -> List (Html Msg)
flightsTab model =
    let
        destination =
            case model.selectedDestination of
                Nothing ->
                    ""

                Just dest ->
                    dest
    in
        [ img [ src "/assets/img/city-default-sml.jpg" ] []
        , div [] <| routesList <| getRoutesForLocation destination model.mapData
        , div [ class "grid__container" ]
            [ dateGrid <| Debug.log "date options list: " model.dateGrid ]
        ]


dateGrid : Maybe Response.DateGrid -> Html Msg
dateGrid grid =
    case grid of
        Nothing ->
            text ""

        Just grid ->
            table [ class "grid__table" ]
                [ thead [] <|
                    List.map
                        (displayHeaderCell)
                        grid.columnHeaders
                , tbody [] <|
                    List.map dateGridRow grid.rows
                ]


displayHeaderCell : Maybe String -> Html Msg
displayHeaderCell content =
    case content of
        Nothing ->
            th [] []

        Just content ->
            th [ class "grid__cell grid__cell--header" ] [ text content ]


dateGridRow : Response.DateGridRow -> Html Msg
dateGridRow row =
    tr [] <|
        [ td [ class "grid__cell grid__cell--header" ] [ text row.rowHeader ] ]
            ++ List.map displayCell row.cells


displayCell : Maybe Response.DateGridCell -> Html Msg
displayCell cell =
    case cell of
        Nothing ->
            td [ class "grid__cell grid__cell--empty" ] []

        Just cell ->
            td [] [ text cell.priceDisplay ]


routesList : Response.Routes -> List (Html Msg)
routesList routes =
    List.map routeItem routes


routeItem : Response.Route -> Html Msg
routeItem route =
    div []
        [ h4 [] [ text route.destination.placeName ]
        , div [] [ text <| "Departure Date: " ++ route.departureDate ]
        , div [] [ text <| "Price:  " ++ route.priceDisplay ]
        ]


getRoutesForLocation : String -> Response.Routes -> Response.Routes
getRoutesForLocation locationId routes =
    let
        filterFunc =
            \n -> n.destination.airportCode == locationId
    in
        List.filter filterFunc routes
