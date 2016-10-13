module UIComponents.Map.Sidebar.CostOfLivingView exposing (..)

import UIComponents.Map.Sidebar.SidebarModel as SidebarModel
import UIComponents.Map.Messages exposing (Msg(..))
import UIComponents.Map.Sidebar.SidebarMessages exposing (SidebarMsg(..))
import UIComponents.Types exposing (RemoteData(..))
import Material
import Material.Spinner as Loading
import Material.Options as Options
import Html exposing (..)
import Html.Attributes exposing (class, href)
import API.CostOfLiving as CostOfLiving


type alias ItemDisplay =
    { icon : String
    , name : String
    , cost : String
    }


view : Material.Model -> SidebarModel.SidebarModel -> Html Msg
view mdl model =
    case model.costOfLivingData of
        Empty ->
            text "No Cost of Living Data found for this city"

        Loading ->
            div [ class "loading-spinner" ]
                [ Loading.spinner
                    [ Loading.active True
                    , Loading.singleColor True
                    ]
                ]

        Failure err ->
            div [ class "sidebar--block" ]
                [ div []
                    [ text "Unfortunately, we don't yet have data for this location, but we're working on expanding our coverage "
                    , text "(this can be because it isn't near a large city, or simply because we haven't associated this airport with a given city yet)"
                    ]
                ]

        Success data ->
            prices data


prices : CostOfLiving.CostOfLiving -> Html Msg
prices data =
    div []
        [ div [ class "attribution" ]
            [ text "Source: "
            , a [ href "numbeo.com" ] [ text "numbeo.com" ]
            ]
        , div [ class "cost-list" ] <|
            List.map itemGroup <|
                items data
        ]


itemGroup : List (ItemDisplay) -> Html Msg
itemGroup list =
    div [ class "cost-list__group" ] <|
        List.map colItem list


colItem : ItemDisplay -> Html Msg
colItem item =
    div [ class "cost-item mdl-grid" ]
        [ div [ class "cost-item__column mdl-cell mdl-cell--4-col" ]
            [ i [ class "material-icons" ] [ text item.icon ] ]
        , div [ class "cost-item__column mdl-cell mdl-cell--4-col" ]
            [ span [ class "cost-item__name" ] [ text item.name ] ]
        , div [ class "cost-item__column mdl-cell mdl-cell--4-col" ]
            [ span [ class "cost-item__column" ] [ text <| "€" ++ item.cost ] ]
        ]


items : CostOfLiving.CostOfLiving -> List (List ItemDisplay)
items data =
    let
        prices =
            data.prices
    in
        [ [ { name = "Inexpensive Meal", icon = "local_dining", cost = prices.inexpensiveMeal }
          , { name = "Mid-range two person meal", icon = "restaurant", cost = prices.midRangeTwoPersonMeal }
          , { name = "Domestic beer (draught)", icon = "local_drink", cost = prices.domesticBeerDraught }
          , { name = "Imported beer (bottled, restaurant)", icon = "local_bar", cost = prices.importedBeerBottleRestaurant }
          ]
        ]
