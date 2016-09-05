module Main exposing (..)

-- Core and Third party packages

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App


-- Custom Packages

import View exposing (view)
import Messages exposing (Msg(..), Route(..))
import Model exposing (Model)
import UIComponents.Menu as Menu
import UIComponents.Map as Map
import UIComponents.Filters as Filters


init : ( Model, Cmd Msg )
init =
    ( { menuModel = Menu.initialModel
      , route = ""
      , mapModel = Map.initialModel
      , filtersModel = Filters.model
      }
    , Cmd.map MapMsg Map.initialCmd
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MenuMsg msg ->
            let
                ( newModel, newCmd ) =
                    Menu.update msg model.menuModel
            in
                ( { model | menuModel = newModel }, Cmd.map MenuMsg newCmd )

        MapMsg msg ->
            let
                ( newModel, newCmd ) =
                    Map.update msg model.mapModel
            in
                ( { model | mapModel = newModel }, Cmd.map MapMsg newCmd )

        FilterMsg msg ->
            let
                ( newFiltersModel, newFiltersCmd ) =
                    Filters.update msg model.filtersModel

                filterCriteria =
                    Filters.getCriteria newFiltersModel

                ( newMapModel, newMapCmd ) =
                    Map.update (Map.ChangeCriteria filterCriteria) model.mapModel
            in
                ( { model | filtersModel = newFiltersModel, mapModel = newMapModel }
                , Cmd.batch
                    [ Cmd.map MapMsg newMapCmd
                    , Cmd.map FilterMsg newFiltersCmd
                    ]
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MenuMsg (Menu.subscriptions model.menuModel)
        , Sub.map MapMsg (Map.subscriptions model.mapModel)
        , Sub.map FilterMsg (Filters.subscriptions model.filtersModel)
        ]


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
