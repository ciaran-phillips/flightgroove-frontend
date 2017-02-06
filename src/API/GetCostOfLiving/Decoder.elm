module API.GetCostOfLiving.Decoder exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:))
import API.GetCostOfLiving.Types exposing (..)


decoder : Json.Decode.Decoder CostOfLiving
decoder =
    ("costOfLiving" := costOfLivingDecoder)


costOfLivingDecoder : Json.Decode.Decoder CostOfLiving
costOfLivingDecoder =
    Json.Decode.succeed CostOfLiving
        |: ("city" := Json.Decode.string)
        |: ("cityId" := Json.Decode.string)
        |: ("summary" := decodeTravelCosts)
        |: ("prices" := decodePrices)


decodeTravelCosts : Json.Decode.Decoder TravelCosts
decodeTravelCosts =
    Json.Decode.succeed TravelCosts
        |: ("hostelIndex" := Json.Decode.string)
        |: ("hotelIndex" := Json.Decode.string)
        |: ("backpackerTravelCostIndex" := Json.Decode.string)
        |: ("travelCostsIndex" := Json.Decode.string)
        |: ("backpackerCostPerDay" := Json.Decode.string)
        |: ("travelCostPerDay" := Json.Decode.string)


decodePrices : Json.Decode.Decoder Prices
decodePrices =
    Json.Decode.succeed Prices
        |: ("inexpensiveMeal" := Json.Decode.string)
        |: ("midRangeTwoPersonMeal" := Json.Decode.string)
        |: ("comboMeal" := Json.Decode.string)
        |: ("domesticBeerDraught" := Json.Decode.string)
        |: ("importedBeerBottleRestaurant" := Json.Decode.string)
        |: ("waterBottleRestaurant" := Json.Decode.string)
        |: ("oneLitreMilk" := Json.Decode.string)
        |: ("loafBread" := Json.Decode.string)
        |: ("kiloCheese" := Json.Decode.string)
        |: ("bottleWineShop" := Json.Decode.string)
        |: ("domesticBeerBottleShop" := Json.Decode.string)
        |: ("importedBeerBottleShop" := Json.Decode.string)
        |: ("publicTransportOneWay" := Json.Decode.string)
        |: ("publicTransportMonthlyPass" := Json.Decode.string)
        |: ("litreGasoline" := Json.Decode.string)
        |: ("oneBedCityCentre" := Json.Decode.string)
        |: ("oneBedOutsideCentre" := Json.Decode.string)
        |: ("monthlyInternet" := Json.Decode.string)
        |: ("averageNetSalary" := Json.Decode.string)
        |: ("taxiStart" := Json.Decode.string)
        |: ("taxiOneKm" := Json.Decode.string)
        |: ("taxiOneHr" := Json.Decode.string)
        |: ("kiloBeef" := Json.Decode.string)


encodeCostOfLiving : CostOfLiving -> Json.Encode.Value
encodeCostOfLiving record =
    Json.Encode.object
        [ ( "city", Json.Encode.string <| record.city )
        , ( "cityId", Json.Encode.string <| record.cityId )
        , ( "summary", encodeCostOfLivingSummary <| record.summary )
        , ( "prices", encodeCostOfLivingPrices <| record.prices )
        ]


encodeCostOfLivingSummary : TravelCosts -> Json.Encode.Value
encodeCostOfLivingSummary record =
    Json.Encode.object
        [ ( "hostelIndex", Json.Encode.string <| record.hostelIndex )
        , ( "hotelIndex", Json.Encode.string <| record.hotelIndex )
        , ( "backpackerTravelCostIndex", Json.Encode.string <| record.backpackerTravelCostIndex )
        , ( "travelCostsIndex", Json.Encode.string <| record.travelCostsIndex )
        , ( "backpackerCostPerDay", Json.Encode.string <| record.backpackerCostPerDay )
        , ( "travelCostPerDay", Json.Encode.string <| record.travelCostPerDay )
        ]


encodeCostOfLivingPrices : Prices -> Json.Encode.Value
encodeCostOfLivingPrices record =
    Json.Encode.object
        [ ( "inexpensiveMeal", Json.Encode.string <| record.inexpensiveMeal )
        , ( "midRangeTwoPersonMeal", Json.Encode.string <| record.midRangeTwoPersonMeal )
        , ( "comboMeal", Json.Encode.string <| record.comboMeal )
        , ( "domesticBeerDraught", Json.Encode.string <| record.domesticBeerDraught )
        , ( "importedBeerBottleRestaurant", Json.Encode.string <| record.importedBeerBottleRestaurant )
        , ( "waterBottleRestaurant", Json.Encode.string <| record.waterBottleRestaurant )
        , ( "oneLitreMilk", Json.Encode.string <| record.oneLitreMilk )
        , ( "loafBread", Json.Encode.string <| record.loafBread )
        , ( "kiloCheese", Json.Encode.string <| record.kiloCheese )
        , ( "bottleWineShop", Json.Encode.string <| record.bottleWineShop )
        , ( "domesticBeerBottleShop", Json.Encode.string <| record.domesticBeerBottleShop )
        , ( "importedBeerBottleShop", Json.Encode.string <| record.importedBeerBottleShop )
        , ( "publicTransportOneWay", Json.Encode.string <| record.publicTransportOneWay )
        , ( "publicTransportMonthlyPass", Json.Encode.string <| record.publicTransportMonthlyPass )
        , ( "litreGasoline", Json.Encode.string <| record.litreGasoline )
        , ( "oneBedCityCentre", Json.Encode.string <| record.oneBedCityCentre )
        , ( "oneBedOutsideCentre", Json.Encode.string <| record.oneBedOutsideCentre )
        , ( "monthlyInternet", Json.Encode.string <| record.monthlyInternet )
        , ( "averageNetSalary", Json.Encode.string <| record.averageNetSalary )
        , ( "taxiStart", Json.Encode.string <| record.taxiStart )
        , ( "taxiOneKm", Json.Encode.string <| record.taxiOneKm )
        , ( "taxiOneHr", Json.Encode.string <| record.taxiOneHr )
        , ( "kiloBeef", Json.Encode.string <| record.kiloBeef )
        ]
