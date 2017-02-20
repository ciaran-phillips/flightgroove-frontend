module API.Decoders.CostOfLiving exposing (costOfLiving)

import Json.Encode
import Json.Decode exposing (field)
import Json.Decode.Extra exposing ((|:))
import API.Types.CostOfLiving exposing (..)


costOfLiving : Json.Decode.Decoder CostOfLiving
costOfLiving =
    (field "costOfLiving" costOfLivingDecoder)


costOfLivingDecoder : Json.Decode.Decoder CostOfLiving
costOfLivingDecoder =
    Json.Decode.succeed CostOfLiving
        |: (field "city" Json.Decode.string)
        |: (field "cityId" Json.Decode.string)
        |: (field "summary" decodeTravelCosts)
        |: (field "prices" decodePrices)


decodeTravelCosts : Json.Decode.Decoder TravelCosts
decodeTravelCosts =
    Json.Decode.succeed TravelCosts
        |: (field "hostelIndex" Json.Decode.string)
        |: (field "hotelIndex" Json.Decode.string)
        |: (field "backpackerTravelCostIndex" Json.Decode.string)
        |: (field "travelCostsIndex" Json.Decode.string)
        |: (field "backpackerCostPerDay" Json.Decode.string)
        |: (field "travelCostPerDay" Json.Decode.string)


decodePrices : Json.Decode.Decoder Prices
decodePrices =
    Json.Decode.succeed Prices
        |: (field "inexpensiveMeal" Json.Decode.string)
        |: (field "midRangeTwoPersonMeal" Json.Decode.string)
        |: (field "comboMeal" Json.Decode.string)
        |: (field "domesticBeerDraught" Json.Decode.string)
        |: (field "importedBeerBottleRestaurant" Json.Decode.string)
        |: (field "waterBottleRestaurant" Json.Decode.string)
        |: (field "oneLitreMilk" Json.Decode.string)
        |: (field "loafBread" Json.Decode.string)
        |: (field "kiloCheese" Json.Decode.string)
        |: (field "bottleWineShop" Json.Decode.string)
        |: (field "domesticBeerBottleShop" Json.Decode.string)
        |: (field "importedBeerBottleShop" Json.Decode.string)
        |: (field "publicTransportOneWay" Json.Decode.string)
        |: (field "publicTransportMonthlyPass" Json.Decode.string)
        |: (field "litreGasoline" Json.Decode.string)
        |: (field "oneBedCityCentre" Json.Decode.string)
        |: (field "oneBedOutsideCentre" Json.Decode.string)
        |: (field "monthlyInternet" Json.Decode.string)
        |: (field "averageNetSalary" Json.Decode.string)
        |: (field "taxiStart" Json.Decode.string)
        |: (field "taxiOneKm" Json.Decode.string)
        |: (field "taxiOneHr" Json.Decode.string)
        |: (field "kiloBeef" Json.Decode.string)


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
