module UIComponents.Map.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class)
import UIComponents.Map.Messages exposing (Msg)
import UIComponents.Map.Model exposing (Model)


view : Model -> Html Msg
view model =
    let
        sidebar =
            case model.selectedDestination of
                Nothing ->
                    Debug.log "no selected destination" <| text ""

                Just dest ->
                    viewSidebar dest
    in
        div [ class "map-wrapper" ]
            [ sidebar
            , div [ id mapId ] []
            ]


viewSidebar : String -> Html Msg
viewSidebar dest =
    div [ class "sidebar" ]
        [ div [ class "sidebar--block" ] [ h3 [] [ text "Berlin, Germany" ] ]
        , div [ class "sidebar--block" ]
            [ div [] [ h4 [] [ text "Cost of Living" ] ]
            , div [] [ h4 [] [ text "Flights" ] ]
            , div [] [ h4 [] [ text "Hotel Prices" ] ]
            ]
        ]


mapId : String
mapId =
    "map"
