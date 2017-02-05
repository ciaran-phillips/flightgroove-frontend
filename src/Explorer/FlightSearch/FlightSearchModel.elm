module Explorer.FlightSearch.FlightSearchModel
    exposing
        ( init
        , FlightSearchModel
        , InitialFlightCriteria
        )

import Explorer.Messages exposing (..)
import Explorer.FlightSearch.FlightSearchMessages exposing (..)
import API.PollLivePricing as PollLivePricing
import API.StartLivePricing as StartLivePricing
import Task


type alias FlightSearchModel =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    , pollingUrl : Maybe String
    , pollingFinished : Bool
    , pollingIncrement : Int
    , flights : Maybe PollLivePricing.PollLivePricingResponse
    }


type alias InitialFlightCriteria =
    { origin : String
    , destination : String
    , outboundDate : String
    , inboundDate : String
    }


pollingIncrement : Int
pollingIncrement =
    1000


init : InitialFlightCriteria -> ( FlightSearchModel, Cmd Msg )
init criteria =
    let
        model =
            initialModel criteria
    in
        ( model, initialCmd model )


initialModel : InitialFlightCriteria -> FlightSearchModel
initialModel criteria =
    { origin = criteria.origin
    , destination = criteria.destination
    , outboundDate = criteria.outboundDate
    , inboundDate = criteria.inboundDate
    , pollingUrl = Nothing
    , pollingFinished = False
    , pollingIncrement = pollingIncrement
    , flights = Nothing
    }


initialCmd : FlightSearchModel -> Cmd Msg
initialCmd model =
    Task.perform
        (FlightSearchTag << StartLivePricingFailure)
        (FlightSearchTag << StartLivePricingSuccess)
    <|
        StartLivePricing.startLivePricing <|
            StartLivePricing.StartLivePricingParams
                model.origin
                model.destination
                model.outboundDate
                model.inboundDate
