module Explorer.FlightSearch.FlightSearchUpdate exposing (..)

import Explorer.FlightSearch.FlightSearchModel exposing (FlightSearchModel, FlightsForOrigin(..), OriginFlights)
import Explorer.FlightSearch.FlightSearchMessages exposing (..)
import Explorer.FlightSearch.FlightSearchCommands as FlightSearchCommands
import Explorer.Messages exposing (Msg)
import API.PollLivePricing.Types exposing (PollLivePricingResponse)
import API.StartLivePricing.Action exposing (StartLivePricingResponse)


update : FlightSearchModel -> FlightSearchMsg -> ( FlightSearchModel, Cmd Msg )
update model msg =
    case msg of
        StartLivePricingSuccess originNum response ->
            let
                newModel =
                    startLivePricingUpdateModel model originNum response
            in
                ( newModel
                , FlightSearchCommands.pollPrices originNum newModel
                )

        StartLivePricingFailure originNum err ->
            startLivePricingFailure model originNum err

        PollLivePricingSuccess originNum response ->
            let
                newModel =
                    pollLivePricingUpdateModel model originNum response
            in
                ( newModel
                , FlightSearchCommands.pollPrices originNum newModel
                )

        PollLivePricingFailure originNum err ->
            ( always model <| Debug.log "Polling error is " err, Cmd.none )

        SelectFlightsTab tab ->
            { model | activeTab = tab } ! []

        CloseFlightSearch ->
            model ! []


startLivePricingUpdateModel : FlightSearchModel -> OriginNumber -> StartLivePricingResponse -> FlightSearchModel
startLivePricingUpdateModel model originNum response =
    case model.flightsForOrigin of
        SingleOrigin firstOrigin ->
            case originNum of
                FirstOrigin ->
                    { model
                        | flightsForOrigin =
                            SingleOrigin <|
                                { firstOrigin | pollingUrl = Just response.location }
                    }

                SecondOrigin ->
                    model

        MultipleOrigins firstOrigin secondOrigin ->
            case originNum of
                FirstOrigin ->
                    { model
                        | flightsForOrigin =
                            MultipleOrigins
                                { firstOrigin | pollingUrl = Just response.location }
                                secondOrigin
                    }

                SecondOrigin ->
                    { model
                        | flightsForOrigin =
                            MultipleOrigins
                                firstOrigin
                                { secondOrigin | pollingUrl = Just response.location }
                    }


startLivePricingFailure model originNum err =
    ( always model <| Debug.log "Start pricing error is " err, Cmd.none )


pollLivePricingUpdateModel : FlightSearchModel -> OriginNumber -> PollLivePricingResponse -> FlightSearchModel
pollLivePricingUpdateModel model originNum response =
    case model.flightsForOrigin of
        SingleOrigin firstOrigin ->
            case originNum of
                FirstOrigin ->
                    { model
                        | flightsForOrigin =
                            SingleOrigin <|
                                updateOriginAfterPoll firstOrigin response
                    }

                SecondOrigin ->
                    model

        MultipleOrigins firstOrigin secondOrigin ->
            case originNum of
                FirstOrigin ->
                    { model
                        | flightsForOrigin =
                            MultipleOrigins
                                (updateOriginAfterPoll firstOrigin response)
                                secondOrigin
                    }

                SecondOrigin ->
                    { model
                        | flightsForOrigin =
                            MultipleOrigins firstOrigin <|
                                updateOriginAfterPoll secondOrigin response
                    }


updateOriginAfterPoll : OriginFlights -> PollLivePricingResponse -> OriginFlights
updateOriginAfterPoll origin response =
    { origin
        | pollingFinished = Debug.log "" response.completed
        , flightData = Just response
    }



-- ( newModel, FlightSearchCommands.pollPrices originNum newModel )
