module Main exposing (..)

-- Core and Third party packages

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App


-- Custom Packages

import View exposing (view)
import Messages exposing (Msg(..))
import Model exposing (Model)
import Explorer.Commands as ExplorerCommands
import Explorer.Subscriptions as ExplorerSubscriptions
import Explorer.Model as ExplorerModel
import Explorer.Update as ExplorerUpdate
import Explorer.Messages as ExplorerMessages
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
        ( { explorerModel = ExplorerModel.initialModel flags.currentMonth
          , filtersModel = filtersModel
          , filterDrawerOpen = False
          }
        , Cmd.batch
            [ Cmd.map ExplorerMsg ExplorerCommands.initialCmd
            , Cmd.map FilterMsg filtersCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ExplorerMsg msg ->
            let
                ( newModel, newCmd ) =
                    ExplorerUpdate.update msg model.explorerModel
            in
                ( { model | explorerModel = newModel }, Cmd.map ExplorerMsg newCmd )

        FilterMsg msg ->
            let
                ( newFiltersModel, newFiltersCmd ) =
                    Filters.update msg model.filtersModel

                filterCriteria =
                    Filters.getCriteria newFiltersModel

                ( newExplorerModel, newMapCmd ) =
                    case filterCriteria of
                        Nothing ->
                            model.explorerModel ! []

                        Just criteria ->
                            ExplorerUpdate.update (ExplorerMessages.ChangeCriteria criteria) model.explorerModel
            in
                ( { model | filtersModel = newFiltersModel, explorerModel = newExplorerModel }
                , Cmd.batch
                    [ Cmd.map ExplorerMsg newMapCmd
                    , Cmd.map FilterMsg newFiltersCmd
                    ]
                )

        ToggleFilterDrawer ->
            { model | filterDrawerOpen = not model.filterDrawerOpen } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map ExplorerMsg (ExplorerSubscriptions.subscriptions model.explorerModel)
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
