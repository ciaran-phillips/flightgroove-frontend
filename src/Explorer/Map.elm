port module Explorer.Map exposing (..)

import Explorer.Ports as Ports
import Explorer.Messages as Messages
import Explorer.MapComp.MapMessages as MapMessages
import Explorer.Update as Update
import Explorer.View as View
import Explorer.Model as Model
import Html exposing (Html)


type alias Model =
    Model.Model


type alias Msg =
    Messages.Msg


initialModel : String -> Model
initialModel initialMonth =
    Model.initialModel initialMonth


initialCmd : Cmd Msg
initialCmd =
    Ports.map
        "map"


view : Model -> Html Msg
view =
    View.view


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    Update.update msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Ports.mapCallback <| Messages.MapTag << MapMessages.MapResponse
        , Ports.popupCallback <| Messages.MapTag << MapMessages.PopupResponse
        , Ports.popupSelected <| Messages.MapTag << MapMessages.SelectDestination
        ]
