module Main exposing (..)

-- Core and Third party packages

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App


-- Custom Packages

import View exposing (view)
import Messages exposing (Msg(..), Route(..))
import Model exposing (Model)
import UIComponents.Map.Map as Map
import UIComponents.Map.Messages as MapMessages
import UIComponents.Map.Filters.Filters as Filters


init : ( Model, Cmd Msg )
init =
    let
        ( filtersModel, filtersCmd ) =
            Filters.init
    in
        ( { route = ""
          , mapModel = Map.initialModel
          , filtersModel = filtersModel
          }
        , Cmd.batch
            [ Cmd.map MapMsg Map.initialCmd
            , Cmd.map FilterMsg filtersCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
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
                    case filterCriteria of
                        Nothing ->
                            model.mapModel ! []

                        Just criteria ->
                            Map.update (MapMessages.ChangeCriteria criteria) model.mapModel
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
        [ Sub.map MapMsg (Map.subscriptions model.mapModel)
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
