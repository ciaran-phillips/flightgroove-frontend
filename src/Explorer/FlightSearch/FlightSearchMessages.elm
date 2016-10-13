module Explorer.FlightSearch.FlightSearchMessages exposing (..)

import API.StartLivePricing.Action exposing (StartLivePricingResponse)
import API.PollLivePricing.Types exposing (PollLivePricingResponse)
import Http


type FlightSearchMsg
    = StartLivePricingSuccess OriginNumber StartLivePricingResponse
    | StartLivePricingFailure OriginNumber Http.Error
    | PollLivePricingSuccess OriginNumber PollLivePricingResponse
    | PollLivePricingFailure OriginNumber Http.Error
    | CloseFlightSearch
    | SelectFlightsTab Int


type OriginNumber
    = FirstOrigin
    | SecondOrigin
