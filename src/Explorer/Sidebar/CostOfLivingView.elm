module Explorer.Sidebar.CostOfLivingView exposing (..)

import Explorer.Sidebar.SidebarModel as SidebarModel
import Explorer.Messages exposing (Msg(..))
import Explorer.Sidebar.SidebarMessages exposing (SidebarMsg(..))
import Explorer.Types exposing (RemoteData(..))
import Material
import Material.Spinner as Loading
import Material.Options as Options
import Html exposing (..)
import Html.Attributes exposing (class)
import API.GetCostOfLiving.Types as CostOfLivingTypes


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
            div []
                [ Loading.spinner
                    [ Loading.active True
                    , Loading.singleColor True
                    ]
                , text "loading"
                ]

        Failure err ->
            always (p [] [ text "Problem loading data for this city" ]) <| Debug.log "error is: " err

        Success data ->
            prices data


prices : CostOfLivingTypes.CostOfLiving -> Html Msg
prices data =
    div [ class "cost-list" ] <|
        List.map itemGroup <|
            items data


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


items : CostOfLivingTypes.CostOfLiving -> List (List ItemDisplay)
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
