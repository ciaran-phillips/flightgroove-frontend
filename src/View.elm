module View exposing (..)

-- Core and Third Party Modules

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.App
import Html.Events exposing (onClick)


-- Custom Modules

import Messages exposing (Msg(..))
import Model exposing (Model)
import Explorer.View as ExplorerView
import Explorer.Filters.Filters as Filters


view : Model -> Html Msg
view model =
    basePage model


basePage : Model -> Html Msg
basePage model =
    div [ class "wrapper" ]
        [ div [ class "header-mobile" ]
            [ div [ class "header-mobile__logo" ] [ text "flightgroove" ]
            , div [ onClick ToggleMenuDrawer, class "header-mobile__menu" ]
                [ text "Options "
                , i [ class "material-icons" ] [ text "menu" ]
                ]
            , div [ class "clearing" ] []
            ]
        , div
            [ classList
                [ ( "filter-bar drawer drawer--right drawer--mobile", True )
                , ( "is-open", model.menuDrawerOpen )
                ]
            ]
            [ div [ class "drawer__overlay", onClick ToggleMenuDrawer ] []
            , div [ class "drawer__body" ]
                [ Html.App.map ExplorerMsg <|
                    ExplorerView.viewMenu model.explorerModel
                ]
            ]
        , div [ class "body" ]
            [ Html.App.map ExplorerMsg <|
                ExplorerView.viewFlightMap model.explorerModel
            ]
        ]
