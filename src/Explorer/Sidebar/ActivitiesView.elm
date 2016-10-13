module Explorer.Sidebar.ActivitiesView exposing (..)

import Material
import Explorer.Sidebar.SidebarModel as SidebarModel
import Explorer.Sidebar.SidebarMessages exposing (..)
import Explorer.Messages exposing (..)
import Explorer.Types exposing (RemoteData(..))
import API.GetActivities.Types exposing (Activities, Activity)
import Html exposing (..)
import Html.Attributes exposing (class, src, colspan)
import Material.Spinner as Loading


view : Material.Model -> SidebarModel.SidebarModel -> Html Msg
view mdl model =
    case model.activities of
        Empty ->
            text "No activities loaded"

        Loading ->
            div [ class "loading-spinner" ]
                [ Loading.spinner
                    [ Loading.active True
                    , Loading.singleColor True
                    ]
                ]

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
