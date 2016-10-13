module UIComponents.Map.FlightSearch.FlightSearchMessages exposing (..)

import API.StartLivePricing exposing (StartLivePricingResponse)
import API.PollLivePricing exposing (PollLivePricingResponse)
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
