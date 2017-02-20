module Explorer.FlightSearch.FlightSearchCommands exposing (..)

import API.Types.LivePricing exposing (PollLivePricingResponse)
import API.Calls as API
import Explorer.FlightSearch.FlightSearchModel exposing (FlightSearchModel, FlightsForOrigin(..), OriginFlights)
import Explorer.Messages exposing (Msg(..))
import Explorer.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg(..), OriginNumber(..))
import Task
import Process
import Http


pollPrices : OriginNumber -> FlightSearchModel -> Cmd Msg
pollPrices numberTag model =
    case numberTag of
        FirstOrigin ->
            pollFirstOrigin model

        SecondOrigin ->
            pollSecondOrigin model


pollFirstOrigin : FlightSearchModel -> Cmd Msg
pollFirstOrigin model =
    case model.flightsForOrigin of
        SingleOrigin originAndFlights ->
            pollOrigin model FirstOrigin originAndFlights

        MultipleOrigins originAndFlights secondOriginAndFlights ->
            pollOrigin model FirstOrigin originAndFlights


pollSecondOrigin : FlightSearchModel -> Cmd Msg
pollSecondOrigin model =
    case model.flightsForOrigin of
        SingleOrigin originAndFlights ->
            Cmd.none

        MultipleOrigins originAndFlights secondOriginAndFlights ->
            pollOrigin model SecondOrigin secondOriginAndFlights


pollOrigin : FlightSearchModel -> OriginNumber -> OriginFlights -> Cmd Msg
pollOrigin model numberTag originAndFlights =
    case originAndFlights.pollingUrl of
        Nothing ->
            Cmd.none

        Just url ->
            if Debug.log "polling finished is " originAndFlights.pollingFinished then
                Cmd.none
            else
                Task.perform
                    (FlightSearchTag << PollLivePricingFailure numberTag)
                    (FlightSearchTag << PollLivePricingSuccess numberTag)
                <|
                    delayedPoll
                        url
                        (createParams model originAndFlights.origin)
                        model.pollingIncrement


delayedPoll : String -> API.PollLivePricingParams -> Int -> Task.Task Http.Error PollLivePricingResponse
delayedPoll url params timeDelay =
    let
        pollTask =
            API.pollLivePricing (Debug.log "poll url is: " url) (Debug.log "params are" params)

        sleepTask =
            Process.sleep <| toFloat <| Debug.log "time delay is" timeDelay
    in
        sleepTask |> Task.andThen (\n -> pollTask)


createParams : FlightSearchModel -> String -> API.PollLivePricingParams
createParams model origin =
    { origin = origin
    , destination = model.destination
    , outboundDate = model.outboundDate
    , inboundDate = model.inboundDate
    }
