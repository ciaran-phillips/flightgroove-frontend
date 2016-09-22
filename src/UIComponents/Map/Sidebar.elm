module UIComponents.Map.Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, src)
import Html.Events exposing (onClick)
import UIComponents.Map.Messages exposing (Msg(..), GridMsg(..))
import UIComponents.Map.Model exposing (Model, GridPosition)
import API.Response as Response
import Array
import Maybe exposing (withDefault)


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
        , div []
            [ dateGrid model.dateGrid model.gridPosition ]
        ]


dateGrid : Maybe Response.DateGrid -> GridPosition -> Html Msg
dateGrid grid position =
    case grid of
        Nothing ->
            text ""

        Just grid ->
            div [ class "grid__container" ]
                [ div [ class "grid__controls grid__controls--top" ] <|
                    gridControlButtonsTop
                , div [ class "clearfix" ] []
                , div [ class "grid__controls grid__controls--side" ] <|
                    gridControlButtonsSide
                , div [ class "grid__overflow-wrapper" ]
                    [ div [ class "grid" ]
                        [ div [ class "grid__sticky-header hide-overflow" ]
                            [ div [ class "grid__slider", style <| [ gridRowOffset position ] ] <|
                                List.map
                                    (displayHeaderCell)
                                    grid.columnHeaders
                            ]
                        , div [ class "grid__sticky-column hide-overflow" ]
                            [ div [ class "grid__slider", style <| [ gridColOffset position ] ] <|
                                List.map (displayHeaderCell << Just << (.rowHeader)) grid.rows
                            ]
                        , div [ class "hide-overflow" ]
                            [ table [ class "grid__table grid__slider", style <| gridTableOffset position ]
                                [ tbody [] <|
                                    List.indexedMap (dateGridRow) grid.rows
                                ]
                            ]
                        ]
                    ]
                ]


gridTableOffset : GridPosition -> List ( String, String )
gridTableOffset pos =
    [ gridRowOffset pos, gridColOffset pos ]


gridRowOffset : GridPosition -> ( String, String )
gridRowOffset pos =
    let
        pixelOffset =
            pos.x * 55
    in
        ( "left", "-" ++ toString pixelOffset ++ "px" )


gridColOffset : GridPosition -> ( String, String )
gridColOffset pos =
    let
        pixelOffset =
            pos.y * 40
    in
        ( "top", "-" ++ toString pixelOffset ++ "px" )


gridControlButtonsTop : List (Html Msg)
gridControlButtonsTop =
    [ button [ class gridControlButtonClass, onClick <| MoveGrid MoveGridLeft ]
        [ i [ class "material-icons" ] [ text "chevron_left" ] ]
    , button [ class gridControlButtonClass, onClick <| MoveGrid MoveGridRight ]
        [ i [ class "material-icons" ] [ text "chevron_right" ] ]
    ]


gridControlButtonsSide : List (Html Msg)
gridControlButtonsSide =
    [ button [ class gridControlButtonClass, onClick <| MoveGrid MoveGridUp ]
        [ i [ class "material-icons" ] [ text "expand_less" ] ]
    , button [ class gridControlButtonClass, onClick <| MoveGrid MoveGridDown ]
        [ i [ class "material-icons" ] [ text "expand_more" ] ]
    ]


gridControlButtonClass : String
gridControlButtonClass =
    "mdl-button mdl-js-button mdl-button--fab mdl-button--mini-fab mdl-js-ripple-effect mdl-button--colored"


displayHeaderCell : Maybe String -> Html Msg
displayHeaderCell content =
    case content of
        Nothing ->
            text ""

        Just content ->
            div [ class "grid__cell grid__cell--header" ] [ text content ]


dateGridRow : Int -> Response.DateGridRow -> Html Msg
dateGridRow rowIndex row =
    tr [] <|
        List.indexedMap (displayCell rowIndex) row.cells


displayCell : Int -> Int -> Maybe Response.DateGridCell -> Html Msg
displayCell rowIndex cellIndex cell =
    case cell of
        Nothing ->
            td [ class "grid__cell" ] []

        Just cell ->
            td [ class "grid__cell grid__cell--selectable", onClick <| SelectGridItem ( rowIndex, cellIndex ) ] [ text cell.priceDisplay ]


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


getTripDatesFromGrid : Int -> Int -> Response.DateGrid -> ( Maybe String, Maybe String )
getTripDatesFromGrid row col grid =
    let
        outboundDate =
            getOutboundDateFromGrid col grid

        inboundDate =
            getInboundDateFromGrid row grid
    in
        ( outboundDate, inboundDate )


getInboundDateFromGrid : Int -> Response.DateGrid -> Maybe String
getInboundDateFromGrid rowIndex grid =
    let
        inboundRow =
            (Array.get rowIndex (Array.fromList grid.rows))
    in
        case inboundRow of
            Nothing ->
                Nothing

            Just row ->
                Just row.rowHeader


getOutboundDateFromGrid : Int -> Response.DateGrid -> Maybe String
getOutboundDateFromGrid colIndex grid =
    withDefault Nothing <|
        Array.get colIndex (Array.fromList grid.columnHeaders)


getRoutesForLocation : String -> Response.Routes -> Response.Routes
getRoutesForLocation locationId routes =
    let
        filterFunc =
            \n -> n.destination.airportCode == locationId
    in
        List.filter filterFunc routes


updateGridPosition : GridMsg -> GridPosition -> Response.DateGrid -> GridPosition
updateGridPosition msg position grid =
    let
        maxPosX =
            List.length grid.columnHeaders - 6

        maxPosY =
            List.length grid.rows - 6
    in
        case msg of
            MoveGridUp ->
                { position | y = decrease 4 position.y 0 }

            MoveGridDown ->
                { position | y = increase 4 position.y maxPosY }

            MoveGridLeft ->
                { position | x = decrease 4 position.x 0 }

            MoveGridRight ->
                { position | x = increase 4 position.x maxPosX }


decrease : Int -> Int -> Int -> Int
decrease stepAmount current minimum =
    if (current - stepAmount) < minimum then
        minimum
    else
        current - stepAmount


increase : Int -> Int -> Int -> Int
increase stepAmount current maximum =
    if (current + stepAmount) > maximum then
        maximum
    else
        current + stepAmount
