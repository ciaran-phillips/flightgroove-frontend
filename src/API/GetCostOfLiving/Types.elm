module API.GetCostOfLiving.Types exposing (..)


type alias Params =
    { cityId : String }


type alias CostOfLiving =
    { city : String
    , cityId : String
    , summary : TravelCosts
    , prices : Prices
    }


type alias TravelCosts =
    { hostelIndex : String
    , hotelIndex : String
    , backpackerTravelCostIndex : String
    , travelCostsIndex : String
    , backpackerCostPerDay : String
    , travelCostPerDay : String
    }


type alias Prices =
    { inexpensiveMeal : String
    , midRangeTwoPersonMeal : String
    , comboMeal : String
    , domesticBeerDraught : String
    , importedBeerBottleRestaurant : String
    , waterBottleRestaurant : String
    , oneLitreMilk : String
    , loafBread : String
    , kiloCheese : String
    , bottleWineShop : String
    , domesticBeerBottleShop : String
    , importedBeerBottleShop : String
    , publicTransportOneWay : String
    , publicTransportMonthlyPass : String
    , litreGasoline : String
    , oneBedCityCentre : String
    , oneBedOutsideCentre : String
    , monthlyInternet : String
    , averageNetSalary : String
    , taxiStart : String
    , taxiOneKm : String
    , taxiOneHr : String
    , kiloBeef : String
    }
