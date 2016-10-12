module Explorer.FlightSearch.FlightSearchMessages exposing (..)

import API.StartLivePricing.Action exposing (StartLivePricingResponse)
import API.PollLivePricing.Types exposing (PollLivePricingResponse)
import Http


type FlightSearchMsg
    = StartLivePricingSuccess StartLivePricingResponse
    | StartLivePricingFailure Http.Error
    | PollLivePricingSuccess PollLivePricingResponse
    | PollLivePricingFailure Http.Error
    | CloseFlightSearch
    | SelectFlightsTab Int
