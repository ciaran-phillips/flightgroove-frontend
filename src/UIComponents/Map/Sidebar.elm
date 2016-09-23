module UIComponents.Map.Sidebar exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, style, src)
import Html.Events exposing (onClick)
import UIComponents.Map.Messages exposing (..)
import UIComponents.Map.Model exposing (Model, SidebarModel, GridSize)
import UIComponents.Map.Types exposing (..)
import API.Response as Response
import Array
import Maybe exposing (withDefault)
import Material


-- THird party packages

import Material.Tabs as Tabs


view : Material.Model -> SidebarModel -> Html Msg
view mdl model =
    div [ class "sidebar" ]
        [ tabs mdl model ]


tabs : Material.Model -> SidebarModel -> Html Msg
tabs mdl model =
    Tabs.render Mdl
        [ 0 ]
        mdl
        [ Tabs.activeTab model.activeTab
        , Tabs.onSelectTab <| SidebarTag << SelectTab
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


flightsTab : SidebarModel -> List (Html Msg)
flightsTab model =
    [ div []
        [ dateGrid model.dateGrid model.gridPosition ]
    ]


dateGrid : RemoteData Response.DateGrid -> GridPosition -> Html Msg
dateGrid grid position =
    case grid of
        Empty ->
            text ""

        Loading ->
            text "Loading"

        Failure err ->
            text "failed to load"

        Success grid ->
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
    [ button [ class gridControlButtonClass, onClick <| SidebarTag <| MoveGrid MoveGridLeft ]
        [ i [ class "material-icons" ] [ text "chevron_left" ] ]
    , button [ class gridControlButtonClass, onClick <| SidebarTag <| MoveGrid MoveGridRight ]
        [ i [ class "material-icons" ] [ text "chevron_right" ] ]
    ]


gridControlButtonsSide : List (Html Msg)
gridControlButtonsSide =
    [ button [ class gridControlButtonClass, onClick <| SidebarTag <| MoveGrid MoveGridUp ]
        [ i [ class "material-icons" ] [ text "expand_less" ] ]
    , button [ class gridControlButtonClass, onClick <| SidebarTag <| MoveGrid MoveGridDown ]
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
            td [ class "grid__cell grid__cell--selectable", onClick <| SidebarTag <| SelectGridItem ( cell.outboundDate, cell.outboundDate ) ] [ text cell.priceDisplay ]


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
