module Explorer.FlightSearch.FlightSearchModel
    exposing
        ( init
        , FlightSearchModel
        , InitialFlightCriteria
        , OriginFlights
        , FlightsForOrigin(..)
        )

import Explorer.Messages exposing (..)
import Explorer.FlightSearch.FlightSearchMessages exposing (..)
import API.PollLivePricing.Types as PollLivePricingTypes
import API.StartLivePricing.Action as StartLivePricing
import Task


type FlightsForOrigin
    = SingleOrigin OriginFlights
    | MultipleOrigins OriginFlights OriginFlights


type alias OriginFlights =
    { origin : Origin
    , flightData : FlightData
    , pollingUrl : Maybe String
    , pollingFinished : Bool
    }


type alias Origin =
    String


type alias FlightData =
    Maybe PollLivePricingTypes.PollLivePricingResponse


type alias FlightSearchModel =
    { destination : String
    , outboundDate : String
    , inboundDate : String
    , pollingIncrement : Int
    , flightsForOrigin : FlightsForOrigin
    , activeTab : Int
    }


type alias InitialFlightCriteria =
    { origin : String
    , secondOrigin : Maybe String
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
    let
        flightsForOrigin =
            case criteria.secondOrigin of
                Nothing ->
                    SingleOrigin <|
                        { origin = criteria.origin
                        , flightData = Nothing
                        , pollingUrl = Nothing
                        , pollingFinished = False
                        }

                Just secondOrigin ->
                    MultipleOrigins
                        { origin = criteria.origin
                        , flightData = Nothing
                        , pollingUrl = Nothing
                        , pollingFinished = False
                        }
                        { origin = secondOrigin
                        , flightData = Nothing
                        , pollingUrl = Nothing
                        , pollingFinished = False
                        }
    in
        { destination = criteria.destination
        , outboundDate = criteria.outboundDate
        , inboundDate = criteria.inboundDate
        , pollingIncrement = pollingIncrement
        , flightsForOrigin = flightsForOrigin
        , activeTab = 0
        }


initialCmd : FlightSearchModel -> Cmd Msg
initialCmd model =
    case model.flightsForOrigin of
        SingleOrigin originAndFlights ->
            startSessionForOrigin model FirstOrigin originAndFlights

        MultipleOrigins originAndFlights secondOriginAndFlights ->
            Cmd.batch
                [ startSessionForOrigin model FirstOrigin originAndFlights
                , startSessionForOrigin model SecondOrigin secondOriginAndFlights
                ]


startSessionForOrigin : FlightSearchModel -> OriginNumber -> OriginFlights -> Cmd Msg
startSessionForOrigin model numberTag originAndFlights =
    Task.perform
        (FlightSearchTag << StartLivePricingFailure numberTag)
        (FlightSearchTag << StartLivePricingSuccess numberTag)
    <|
        StartLivePricing.start <|
            StartLivePricing.StartLivePricingParams
                originAndFlights.origin
                model.destination
                model.outboundDate
                model.inboundDate
