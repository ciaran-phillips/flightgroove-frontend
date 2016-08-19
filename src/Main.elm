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


init : ( Model, Cmd Msg )
init =
    ( { menuModel = Menu.initialModel, route = "" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        MenuMsg msg ->
            let
                ( newModel, newCmd ) =
                    Menu.update msg model.menuModel
            in
                ( { model | menuModel = newModel }, Cmd.map MenuMsg newCmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map MenuMsg (Menu.subscriptions model.menuModel)


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
