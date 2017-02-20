module Explorer.FlightSearch.FlightSearchMessages exposing (..)

import API.Types.LivePricing exposing (StartLivePricingResponse, PollLivePricingResponse)
import Http


type FlightSearchMsg =
    StartLivePricingUpdate OriginNumber (Result Http.Error StartLivePricingResponse)
    | PollLivePricingUpdate OriginNumber (Result Http.Error PollLivePricingResponse)
    | CloseFlightSearch
    | SelectFlightsTab Int


type OriginNumber
    = FirstOrigin
    | SecondOrigin
