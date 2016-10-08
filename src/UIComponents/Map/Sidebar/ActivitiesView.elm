module UIComponents.Map.Sidebar.ActivitiesView exposing (..)

import Material
import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Map.Sidebar.SidebarMessages exposing (..)
import UIComponents.Map.Messages exposing (..)
import UIComponents.Types exposing (RemoteData(..))
import API.Activities exposing (Activities, Activity)
import Html exposing (..)
import Html.Attributes exposing (class, src, colspan)


view : Material.Model -> SidebarModel.SidebarModel -> Html Msg
view mdl model =
    case model.activities of
        Empty ->
            text "No activities loaded"

        Loading ->
            text "loading"

        Success data ->
            div [ class "activities-title" ]
                [ h3 [ class "activities-title__heading" ]
                    [ text <| "Showing Events for " ++ data.destination ]
                , span [ class "activities-title__sub" ]
                    [ text <| "(" ++ data.fullName ++ ")" ]
                , ul
                    [ class "unstyled" ]
                  <|
                    List.map viewActivity data.activities
                ]

        Failure err ->
            always (text "failed due to err") <| Debug.log "activities error: " err


viewActivity : Activity -> Html Msg
viewActivity activity =
    li [ class "activity clearfix" ]
        [ div [ class "activity__img" ]
            [ img [ src activity.imageUrl ] []
            ]
        , div [ class "activity__content" ]
            [ h4 [ class "activity__title" ] [ text activity.title ]
            , table []
                [ tr []
                    [ td [ colspan 2 ] [ text <| "From " ++ activity.fromPrice ++ " " ++ activity.fromPriceLabel ]
                    ]
                , tr []
                    [ td [] [ text "Duration: " ]
                    , td [] [ text activity.duration ]
                    ]
                , tr []
                    [ td [] [ text "Supplier: " ]
                    , td [] [ text activity.supplierName ]
                    ]
                ]
            ]
        ]
