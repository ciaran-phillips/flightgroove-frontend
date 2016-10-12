module UIComponents.Map.FlightSearch.FlightSearchModel
    exposing
        ( init
        , FlightSearchModel
        , InitialFlightCriteria
        , OriginFlights
        , FlightsForOrigin(..)
        )

import UIComponents.Map.Messages exposing (..)
import UIComponents.Map.FlightSearch.FlightSearchMessages exposing (..)
import API.PollLivePricing as PollLivePricing
import API.StartLivePricing as StartLivePricing
import Task


type FlightsForOrigin
    = SingleOrigin OriginFlights
    | MultipleOrigins OriginFlights OriginFlights


type alias OriginFlights =
    { origin : Origin
    , flightData : FlightData
    }


type alias Origin =
    String


type alias FlightData =
    Maybe PollLivePricing.PollLivePricingResponse


type alias FlightSearchModel =
    { destination : String
    , outboundDate : String
    , inboundDate : String
    , pollingUrl : Maybe String
    , pollingFinished : Bool
    , pollingIncrement : Int
    , flightsForOrigin : FlightsForOrigin
    , activeTab : Int
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
    { destination = criteria.destination
    , outboundDate = criteria.outboundDate
    , inboundDate = criteria.inboundDate
    , pollingUrl = Nothing
    , pollingFinished = False
    , pollingIncrement = pollingIncrement
    , flightsForOrigin = SingleOrigin <| OriginFlights criteria.origin Nothing
    , activeTab = 0
    }


initialCmd : FlightSearchModel -> Cmd Msg
initialCmd model =
    let
        origin =
            case model.flightsForOrigin of
                SingleOrigin originAndFlights ->
                    originAndFlights.origin

                MultipleOrigins originAndFlights secondOriginAndFlights ->
                    originAndFlights.origin
    in
        Task.perform
            (FlightSearchTag << StartLivePricingFailure)
            (FlightSearchTag << StartLivePricingSuccess)
        <|
            StartLivePricing.startLivePricing <|
                StartLivePricing.StartLivePricingParams
                    origin
                    model.destination
                    model.outboundDate
                    model.inboundDate
