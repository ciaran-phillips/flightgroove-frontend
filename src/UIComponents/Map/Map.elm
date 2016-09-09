port module UIComponents.Map.Map exposing (..)

import UIComponents.Map.Ports as Ports
import UIComponents.Map.Messages as Messages
import UIComponents.Map.Update as Update
import UIComponents.Map.View as View
import UIComponents.Map.Model as Model
import Html exposing (Html)


type alias Model =
    Model.Model


type alias Msg =
    Messages.Msg


initialModel : Model
initialModel =
    Model.initialModel


initialCmd : Cmd Msg
initialCmd =
    Ports.map "map"


view : Model -> Html Msg
view =
    View.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Update.update msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.mapCallback Messages.MapResponse
        , Ports.popupCallback Messages.PopupResponse
        , Ports.popupSelected Messages.SelectDestination
        ]
