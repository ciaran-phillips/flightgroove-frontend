module UIComponents.Map.Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style)
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
        [ div [] <| routesList <| getRoutesForLocation destination model.mapData
        , div [] [ dateGrid <| Debug.log "date options list: " model.dateOptions ]
        ]


dateGrid : Response.DateOptions -> Html Msg
dateGrid options =
    div [ class "date-grid--row" ] <|
        List.map dateGridItem options


dateGridItem : Response.DateOption -> Html Msg
dateGridItem option =
    let
        getHeight =
            \n -> toString <| (n.price * 100) // 1000
    in
        div [ class "date-grid--column", style [ ( "height", (getHeight option) ++ "px" ) ] ] []


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
