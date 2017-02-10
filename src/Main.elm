module Main exposing (..)

-- Core and Third party packages

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App


-- Custom Packages

import View exposing (view)
import Messages exposing (Msg(..), Route(..))
import Model exposing (Model)
import Explorer.Commands as ExplorerCommands
import Explorer.Subscriptions as ExplorerSubscriptions
import Explorer.Model as ExplorerModel
import Explorer.Update as ExplorerUpdate
import Explorer.Messages as MapMessages
import Explorer.Filters.Filters as Filters


type alias Flags =
    { currentMonth : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( filtersModel, filtersCmd ) =
            Filters.init flags.currentMonth
    in
        ( { route = ""
          , mapModel = ExplorerModel.initialModel flags.currentMonth
          , filtersModel = filtersModel
          , filterDrawerOpen = False
          }
        , Cmd.batch
            [ Cmd.map MapMsg ExplorerCommands.initialCmd
            , Cmd.map FilterMsg filtersCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MapMsg msg ->
            let
                ( newModel, newCmd ) =
                    ExplorerUpdate.update msg model.mapModel
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
                            ExplorerUpdate.update (MapMessages.ChangeCriteria criteria) model.mapModel
            in
                ( { model | filtersModel = newFiltersModel, mapModel = newMapModel }
                , Cmd.batch
                    [ Cmd.map MapMsg newMapCmd
                    , Cmd.map FilterMsg newFiltersCmd
                    ]
                )

        ToggleFilterDrawer ->
            { model | filterDrawerOpen = not model.filterDrawerOpen } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map MapMsg (ExplorerSubscriptions.subscriptions model.mapModel)
        , Sub.map FilterMsg (Filters.subscriptions model.filtersModel)
        ]


main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
