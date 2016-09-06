module View exposing (..)

-- Core and Third Party Modules

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Html.Events exposing (onClick)


-- Custom Modules

import Messages exposing (Msg(..))
import Model exposing (Model)
import UIComponents.Menu as Menu
import UIComponents.Map as Map
import UIComponents.Filters as Filters


view : Model -> Html Msg
view model =
    basePage model


basePage : Model -> Html Msg
basePage model =
    div [ class "wrapper" ]
        [ div []
            [ div [ class "mdl-grid header" ] <| topBarRows model
            , div [ class "mdl-grid filterbar" ] <| filterRows model
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
    , div [ class "mdl-cell mdl-cell--3-col" ] [ outboundDate model ]
    , div [ class "mdl-cell mdl-cell--3-col" ] [ inboundDate model ]
    ]


filterRows : Model -> List (Html Msg)
filterRows model =
    [ div [ class "mdl-cell mdl-cell--3-col" ] []
    , div [ class "mdl-cell mdl-cell--2-col" ] [ Html.App.map MenuMsg (Menu.view model.menuModel) ]
    , div [ class "mdl-cell mdl-cell--2-col" ] []
    , div [ class "mdl-cell mdl-cell--2-col" ] []
    ]


searchBox : Model -> Html Msg
searchBox model =
    filterWrapper "" <|
        Html.App.map FilterMsg <|
            Filters.viewOriginSearch model.filtersModel


outboundDate : Model -> Html Msg
outboundDate model =
    filterWrapper "" <|
        Html.App.map FilterMsg <|
            Filters.viewOutboundDate model.filtersModel


inboundDate : Model -> Html Msg
inboundDate model =
    filterWrapper "" <|
        Html.App.map FilterMsg <|
            Filters.viewInboundDate model.filtersModel


filterWrapper : String -> Html Msg -> Html Msg
filterWrapper labelText filterHtml =
    div [ class "form-group filter" ]
        [ label [] [ text labelText ]
        , div [] [ filterHtml ]
        ]


mapContainer : Model -> Html Msg
mapContainer model =
    Map.view model.mapModel
        |> Html.App.map MapMsg
