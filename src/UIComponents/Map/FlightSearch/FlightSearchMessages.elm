module UIComponents.Map.FlightSearch.FlightSearchMessages exposing (..)

import API.StartLivePricing exposing (StartLivePricingResponse)
import API.PollLivePricing exposing (PollLivePricingResponse)
import Http


type FlightSearchMsg
    = StartLivePricingSuccess StartLivePricingResponse
    | StartLivePricingFailure Http.Error
    | PollLivePricingSuccess PollLivePricingResponse
    | PollLivePricingFailure Http.Error
    | CloseFlightSearch
    | SelectFlightsTab Int
