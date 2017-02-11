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
import Task exposing (Task)
import Http exposing (Error)


type alias GetActivitiesParams =
    { locationQuery : String }


getActivities : GetActivitiesParams -> Task Error ActivitiesTypes.Activities
getActivities params =
    Http.get ActivitiesDecoder.activities <|
        "/api/activities/"
            ++ (Http.uriEncode params.locationQuery)


type alias GetCostOfLivingParams =
    { cityId : String }


getCostOfLiving : GetCostOfLivingParams -> Task Error CostOfLivingTypes.CostOfLiving
getCostOfLiving params =
    Http.get CostOfLivingDecoder.costOfLiving <|
        "/api/costofliving/"
            ++ params.cityId


type alias GetDateGridParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getDateGrid : GetDateGridParams -> Task Error DateGridTypes.DateGrid
getDateGrid params =
    Http.get DateGridDecoder.dateGrid <|
        "api/dategrid/"
            ++ params.origin
            ++ "/"
            ++ params.destination
            ++ "/"
            ++ params.outboundDate
            ++ "/"
            ++ params.inboundDate


type alias GetLocationSuggestionsParams =
    { query : String }


getLocationSuggestions : GetLocationSuggestionsParams -> Task Error LocationTypes.LocationSuggestions
getLocationSuggestions params =
    Http.get
        LocationDecoder.locationSuggestions
    <|
        "/api/origin/"
            ++ params.query


type alias GetRoutesParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getRoutes : GetRoutesParams -> Task Error LocationTypes.Routes
getRoutes params =
    Http.get LocationDecoder.routes <|
        "/api/routes/"
            ++ params.origin
            ++ "/"
            ++ params.destination
            ++ "/"
            ++ params.outboundDate
            ++ "/"
            ++ params.inboundDate


type alias GetRoutesMultipleOriginsParams =
    { origin : String
    , secondOrigin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


getRoutesMultipleOrigins : GetRoutesMultipleOriginsParams -> Task Error LocationTypes.Routes
getRoutesMultipleOrigins params =
    Http.get LocationDecoder.routes <|
        "/api/routes-multiple-origins/"
            ++ (Http.uriEncode params.origin ++ "/")
            ++ (Http.uriEncode params.secondOrigin ++ "/")
            ++ (Http.uriEncode params.destination ++ "/")
            ++ (Http.uriEncode params.outboundDate ++ "/")
            ++ (Http.uriEncode params.inboundDate ++ "/")


getUserLocation : Task Error LocationTypes.LocationSuggestions
getUserLocation =
    Http.get
        LocationDecoder.locationSuggestions
        "/api/get-user-origin/"


type alias PollLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


pollLivePricing : LivePricingTypes.PollingUrl -> PollLivePricingParams -> Task Error LivePricingTypes.PollLivePricingResponse
pollLivePricing url params =
    Http.get LivePricingDecoder.pollLivePricingResponse <|
        "/api/livepricing/poll/"
            ++ (Http.uriEncode url)
            ++ "?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
            ++ ("&originplace=" ++ params.origin)
            ++ ("&destinationplace=" ++ params.destination)
            ++ ("&outbounddate=" ++ params.outboundDate)
            ++ ("&inbounddate=" ++ params.inboundDate)


type alias StartLivePricingParams =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


startLivePricing : StartLivePricingParams -> Task Error LivePricingTypes.StartLivePricingResponse
startLivePricing params =
    Http.get LivePricingDecoder.startLivePricingResponse <|
        "/api/livepricing/start?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
            ++ ("&originplace=" ++ params.origin)
            ++ ("&destinationplace=" ++ params.destination)
            ++ ("&outbounddate=" ++ params.outboundDate)
            ++ ("&inbounddate=" ++ params.inboundDate)
