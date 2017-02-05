module View exposing (..)

-- Core and Third Party Modules

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Html.Events exposing (onClick)


-- Custom Modules

import Messages exposing (Msg(..))
import Model exposing (Model)
import UIComponents.Map.Map as Map
import UIComponents.Map.Filters.Filters as Filters


view : Model -> Html Msg
view model =
    basePage model


basePage : Model -> Html Msg
basePage model =
    div [ class "wrapper" ]
        [ div []
            [ div [ class "mdl-grid header" ] <| topBarRows model
            ]
        , mapContainer model
        ]


topBarRows : Model -> List (Html Msg)
topBarRows model =
    [ div [ class "mdl-cell mdl-cell--3-col logo" ]
        [ div [ class "logo--part" ] [ img [ src "assets/img/logo.png" ] [] ]
        , div [ class "logo--part" ]
            [ div [ class "logo--heading" ] [ text "flightgroove" ]
            , div [ class "logo--tagline" ] [ text "your trip, your way" ]
            ]
        ]
    , div [ class "mdl-cell mdl-cell--3-col" ] [ searchBox model ]
    , div [ class "mdl-cell mdl-cell--3-col" ]
        [ label [] [ text "departure / return dates" ]
        , div [ class "date-inputs form-control" ]
            [ outboundDate model
            , inboundDate model
            ]
        ]
    , div [ class "mdl-cell mdl-cell--2-col" ] [ dateToggle model, originsToggle model ]
    ]


searchBox : Model -> Html Msg
searchBox model =
    Html.App.map FilterMsg <|
        Filters.viewOriginSearch model.filtersModel


outboundDate : Model -> Html Msg
outboundDate model =
    Html.App.map FilterMsg <|
        Filters.viewOutboundDate model.filtersModel


inboundDate : Model -> Html Msg
inboundDate model =
    Html.App.map FilterMsg <|
        Filters.viewInboundDate model.filtersModel


dateToggle : Model -> Html Msg
dateToggle model =
    Html.App.map FilterMsg <|
        Filters.viewToggle model.filtersModel


originsToggle : Model -> Html Msg
originsToggle model =
    text ""


filterWrapper : String -> Html Msg -> Html Msg
filterWrapper labelText filterHtml =
    div [ class "form-group form-control filter" ]
        [ label [] [ text labelText ]
        , div [] [ filterHtml ]
        ]


mapContainer : Model -> Html Msg
mapContainer model =
    Map.view model.mapModel
        |> Html.App.map MapMsg
