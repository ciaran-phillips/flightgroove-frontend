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


type alias Flags =
    { currentMonth : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( model, cmd ) =
            ExplorerModel.init flags.currentMonth
    in
        ( { explorerModel = model
          , menuDrawerOpen = False
          }
        , Cmd.map ExplorerMsg cmd
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

        ToggleMenuDrawer ->
            { model | menuDrawerOpen = not model.menuDrawerOpen } ! []


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map ExplorerMsg (ExplorerSubscriptions.subscriptions model.explorerModel)


main : Program Flags
main =
    Html.App.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
