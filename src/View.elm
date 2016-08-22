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


view : Model -> Html Msg
view model =
    basePage model


basePage : Model -> Html Msg
basePage model =
    div [ class "wrapper" ]
        [ div [ class "container-fluid" ]
            [ div [ class "row header" ] topBarRows
            , div [ class "row filterbar" ] <| filterRows model
            ]
        , mapContainer model
        ]


topBarRows : List (Html Msg)
topBarRows =
    [ div [ class "col-xs-3 logo" ]
        [ div [ class "logo--part" ] [ img [ src "assets/img/logo.png" ] [] ]
        , div [ class "logo--part" ]
            [ div [ class "logo--heading" ] [ text "flightgroove" ]
            , div [ class "logo--tagline" ] [ text "your trip, your way" ]
            ]
        ]
    , div [ class "col-xs-3" ] [ searchBox ]
    , div [ class "col-xs-3" ] []
    , div [ class "col-xs-3" ] []
    ]


filterRows : Model -> List (Html Msg)
filterRows model =
    [ div [ class "col-xs-3" ] []
    , div [ class "col-xs-2" ] [ Html.App.map MenuMsg (Menu.view model.menuModel) ]
    , div [ class "col-xs-2" ] [ text "stopovers" ]
    , div [ class "col-xs-2" ] [ text "pricing" ]
    ]


searchBox : Html Msg
searchBox =
    filterWrapper "" <|
        input [ placeholder "Dublin, Ireland (DUB)", class "form-control" ] []


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
