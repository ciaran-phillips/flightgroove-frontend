module UIComponents.Map.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Model exposing (Model)
import UIComponents.Map.Sidebar as Sidebar


view : Model -> Html Msg
view model =
    let
        sidebar =
            case model.selectedDestination of
                Nothing ->
                    Debug.log "no selected destination" <| text ""

                Just dest ->
                    Sidebar.view model
    in
        div [ class "map-wrapper" ]
            [ sidebar
            , div [ id mapId ] []
            ]


mapId : String
mapId =
    "map"
