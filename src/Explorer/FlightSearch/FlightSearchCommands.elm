module Explorer.FlightSearch.FlightSearchCommands exposing (..)

import API.PollLivePricing.Types exposing (PollLivePricingParams, PollLivePricingResponse)
import API.PollLivePricing.Action as PollLivePricing
import Explorer.FlightSearch.FlightSearchModel exposing (FlightSearchModel)
import Explorer.Messages exposing (Msg(..))
import Explorer.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg(..))
import Task
import Process
import Http


pollPrices : FlightSearchModel -> Cmd Msg
pollPrices model =
    case model.pollingUrl of
        Nothing ->
            Cmd.none

        Just url ->
            if model.pollingFinished then
                Cmd.none
            else
                Task.perform
                    (FlightSearchTag << PollLivePricingFailure)
                    (FlightSearchTag << PollLivePricingSuccess)
                <|
                    delayedPoll
                        url
                        (createParams model)
                        model.pollingIncrement


delayedPoll : String -> PollLivePricingParams -> Int -> Task.Task Http.Error PollLivePricingResponse
delayedPoll url params timeDelay =
    let
        pollTask =
            PollLivePricing.poll (Debug.log "poll url is: " url) (Debug.log "params are" params)

        sleepTask =
            Process.sleep <| toFloat <| Debug.log "time delay is" timeDelay
    in
        sleepTask `Task.andThen` (\n -> pollTask)


createParams : FlightSearchModel -> PollLivePricingParams
createParams model =
    PollLivePricingParams
        model.origin
        model.destination
        model.outboundDate
        model.inboundDate
