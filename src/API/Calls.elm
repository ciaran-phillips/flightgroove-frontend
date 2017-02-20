module API.Calls exposing (..)

import API.Types.Activities as ActivitiesTypes
import API.Types.CostOfLiving as CostOfLivingTypes
import API.Types.DateGrid as DateGridTypes
import API.Types.LivePricing as LivePricingTypes
import API.Types.Location as LocationTypes
import API.Decoders.Activities as ActivitiesDecoder
import API.Decoders.CostOfLiving as CostOfLivingDecoder
import API.Decoders.DateGrid as DateGridDecoder
import API.Decoders.LivePricing as LivePricingDecoder
import API.Decoders.Location as LocationDecoder
import Http exposing (Error)


type alias GetActivitiesParams =
    { locationQuery : String }


getActivities : GetActivitiesParams -> Http.Request ActivitiesTypes.Activities
getActivities params =
    let url = "/api/activities/"
            ++ (Http.encodeUri params.locationQuery)
    in
      Http.get url ActivitiesDecoder.activities


type alias GetCostOfLivingParams =
    { cityId : String }


getCostOfLiving : GetCostOfLivingParams -> Http.Request CostOfLivingTypes.CostOfLiving
getCostOfLiving params =
    let url = "/api/costofliving/"
            ++ params.cityId
    in
      Http.get url CostOfLivingDecoder.costOfLiving


type alias GetDateGridParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getDateGrid : GetDateGridParams -> Http.Request DateGridTypes.DateGrid
getDateGrid params =
    let url = "api/dategrid/"
            ++ params.origin
            ++ "/"
            ++ params.destination
            ++ "/"
            ++ params.outboundDate
            ++ "/"
            ++ params.inboundDate
    in
      Http.get url DateGridDecoder.dateGrid


type alias GetLocationSuggestionsParams =
    { query : String }


getLocationSuggestions : GetLocationSuggestionsParams -> Http.Request LocationTypes.LocationSuggestions
getLocationSuggestions params =
    let url = "/api/origin/"
            ++ params.query
    in
      Http.get url LocationDecoder.locationSuggestions


type alias GetRoutesParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getRoutes : GetRoutesParams -> Http.Request LocationTypes.Routes
getRoutes params =
    let url = "/api/routes/"
            ++ params.origin
            ++ "/"
            ++ params.destination
            ++ "/"
            ++ params.outboundDate
            ++ "/"
            ++ params.inboundDate
    in
      Http.get url LocationDecoder.routes


type alias GetRoutesMultipleOriginsParams =
    { origin : String
    , secondOrigin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getRoutesMultipleOrigins : GetRoutesMultipleOriginsParams ->  Http.Request LocationTypes.Routes
getRoutesMultipleOrigins params =
    let url = "/api/routes-multiple-origins/"
            ++ (Http.encodeUri params.origin ++ "/")
            ++ (Http.encodeUri params.secondOrigin ++ "/")
            ++ (Http.encodeUri params.destination ++ "/")
            ++ (Http.encodeUri params.outboundDate ++ "/")
            ++ (Http.encodeUri params.inboundDate ++ "/")
    in
      Http.get url LocationDecoder.routes


getUserLocation : Http.Request LocationTypes.LocationSuggestions
getUserLocation =
    Http.get "/api/get-user-origin/" LocationDecoder.locationSuggestions


type alias PollLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


pollLivePricing : LivePricingTypes.PollingUrl -> PollLivePricingParams -> Http.Request LivePricingTypes.PollLivePricingResponse
pollLivePricing url params =
    let urlToFetch = "/api/livepricing/poll/"
            ++ (Http.encodeUri url)
            ++ "?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
            ++ ("&originplace=" ++ params.origin)
            ++ ("&destinationplace=" ++ params.destination)
            ++ ("&outbounddate=" ++ params.outboundDate)
            ++ ("&inbounddate=" ++ params.inboundDate)
    in
      Http.get urlToFetch LivePricingDecoder.pollLivePricingResponse


type alias StartLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


startLivePricing : StartLivePricingParams -> Http.Request LivePricingTypes.StartLivePricingResponse
startLivePricing params =
    let url = "/api/livepricing/start?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
            ++ ("&originplace=" ++ params.origin)
            ++ ("&destinationplace=" ++ params.destination)
            ++ ("&outbounddate=" ++ params.outboundDate)
            ++ ("&inbounddate=" ++ params.inboundDate)
    in
      Http.get url LivePricingDecoder.startLivePricingResponse
