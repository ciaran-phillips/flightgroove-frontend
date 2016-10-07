module UIComponents.Map.Sidebar.SidebarView exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class, style, src)
import Html.Events exposing (onClick)


-- Third party packages

import Material
import Material.Tabs as Tabs


-- Custom Modules

import UIComponents.Map.Messages exposing (Msg(SidebarTag, Mdl))
import UIComponents.Map.Sidebar.SidebarMessages exposing (..)
import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Types exposing (RemoteData(..))
import API.Response as Response
import UIComponents.Map.Sidebar.CostOfLivingView as CostOfLivingView


view : Material.Model -> SidebarModel.SidebarModel -> Html Msg
view mdl model =
    let
        displaySidebarClass =
            if model.sidebarVisible then
                " "
            else
                " is-hidden"
    in
        div [ class <| "sidebar" ++ displaySidebarClass ]
            [ toggleDisplayButton model.sidebarVisible
            , tabs mdl model
            ]



-- PRIVATE FUNCTIONS


tabs : Material.Model -> SidebarModel.SidebarModel -> Html Msg
tabs mdl model =
    Tabs.render Mdl
        [ 0 ]
        mdl
        [ Tabs.activeTab model.activeTab
        , Tabs.onSelectTab <| SidebarTag << SelectTab
        ]
        [ Tabs.label [] [ icon "flight", text "Flights" ]
        , Tabs.label [] [ icon "euro_symbol", text "Cost of Living" ]
        , Tabs.label [] [ icon "place", text "Attractions" ]
        ]
        [ case model.activeTab of
            0 ->
                div [ class "sidebar--block" ] <| flightsTab model

            1 ->
                div [ class "sidebar--block" ] <| [ CostOfLivingView.view mdl model ]

            _ ->
                div [ class "sidebar--block" ] [ text "Attractions content" ]
        ]


icon : String -> Html Msg
icon iconName =
    i [ class "material-icons" ] [ text iconName ]


flightsTab : SidebarModel.SidebarModel -> List (Html Msg)
flightsTab model =
    [ div []
        [ selectedDateView model
        , dateGrid model model.gridPosition
        ]
    ]


selectedDateView : SidebarModel.SidebarModel -> Html Msg
selectedDateView model =
    let
        estimatedPriceParagraph =
            "Estimated Price per person is "
                ++ model.lowestPrice
                ++ ", departing on "
                ++ model.selectedOutboundDate
                ++ "and returning on "
                ++ model.selectedInboundDate

        disclaimerParagraph =
            [ text "These prices are based on recent flight searches, click"
            , em [] [ text "Show Flights" ]
            , text " to see exact prices, customise stops / passengers / times / dates and more."
            ]
    in
        div []
            [ h5 [] [ text <| model.destination.placeName ++ " (" ++ model.destination.airportCode ++ ")" ]
            , p [] [ text estimatedPriceParagraph ]
            , p [] disclaimerParagraph
            , button
                [ class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"
                , onClick <|
                    SidebarTag <|
                        ShowFlights <|
                            FlightSearchConfig model.destination.airportCode model.selectedOutboundDate model.selectedInboundDate
                ]
                [ text "Show Flights" ]
            ]


dateGrid : SidebarModel.SidebarModel -> SidebarModel.GridPosition -> Html Msg
dateGrid model position =
    case model.dateGrid of
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
                                    List.indexedMap (dateGridRow model) grid.rows
                                ]
                            ]
                        ]
                    ]
                ]


gridTableOffset : SidebarModel.GridPosition -> List ( String, String )
gridTableOffset pos =
    [ gridRowOffset pos, gridColOffset pos ]


gridRowOffset : SidebarModel.GridPosition -> ( String, String )
gridRowOffset pos =
    let
        pixelOffset =
            pos.x * 55
    in
        ( "left", "-" ++ toString pixelOffset ++ "px" )


gridColOffset : SidebarModel.GridPosition -> ( String, String )
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


dateGridRow : SidebarModel.SidebarModel -> Int -> Response.DateGridRow -> Html Msg
dateGridRow model rowIndex row =
    tr [] <|
        List.indexedMap (displayCell model rowIndex) row.cells


displayCell : SidebarModel.SidebarModel -> Int -> Int -> Maybe Response.DateGridCell -> Html Msg
displayCell model rowIndex cellIndex cell =
    case cell of
        Nothing ->
            td [ class "grid__cell" ] []

        Just cell ->
            let
                cellData =
                    { x = cellIndex
                    , y = rowIndex
                    , outboundDate = cell.outboundDate
                    , inboundDate = cell.inboundDate
                    }

                modifierClass =
                    if
                        (cell.outboundDate == model.selectedOutboundDate)
                            && (cell.inboundDate == model.selectedInboundDate)
                    then
                        "grid__cell--selected"
                    else
                        "grid__cell--selectable"
            in
                td
                    [ class <| "grid__cell " ++ modifierClass
                    , onClick <| SidebarTag <| SelectGridItem cellData
                    ]
                    [ text cell.priceDisplay ]


toggleDisplayButton : Bool -> Html Msg
toggleDisplayButton currentVisibility =
    let
        ( action, icon ) =
            if currentVisibility then
                ( SidebarTag CloseSidebar, "chevron_left" )
            else
                ( SidebarTag OpenSidebar, "chevron_right" )
    in
        button [ onClick action, class "sidebar__close" ]
            [ i [ class "material-icons" ] [ text icon ]
            ]
