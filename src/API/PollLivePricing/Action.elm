module API.PollLivePricing.Action exposing (..)

import Http
import Task
import API.PollLivePricing.Types exposing (..)
import API.PollLivePricing.Decoder as Decoder


poll : PollingUrl -> PollLivePricingParams -> Task.Task Http.Error PollLivePricingResponse
poll url params =
    Http.get Decoder.decoder <|
        buildUrl url params


buildUrl : PollingUrl -> PollLivePricingParams -> String
buildUrl url params =
    "/api/livepricing/poll/"
        ++ (Http.uriEncode url)
        ++ "?country=GB-sky&currency=GBP&locale=en-GB&adults=1&locationschema=Sky"
        ++ ("&originplace=" ++ params.origin)
        ++ ("&destinationplace=" ++ params.destination)
        ++ ("&outbounddate=" ++ params.outboundDate)
        ++ ("&inbounddate=" ++ params.inboundDate)



-- Manipulating Response


getSegmentsFromLeg : Leg -> List Segment -> List Segment
getSegmentsFromLeg leg segments =
    List.filter
        (\n -> List.member n.id leg.segments)
        segments


getCarriersFromItinerary : PollLivePricingResponse -> Itinerary -> List Carrier
getCarriersFromItinerary fullFlightData itinerary =
    let
        getLegFunc =
            getLeg fullFlightData.legs itinerary

        getCarrierList =
            \leg ->
                case leg of
                    Nothing ->
                        []

                    Just l ->
                        l.carriers

        outboundCarriers =
            getLegFunc Outbound |> getCarrierList

        inboundCarriers =
            getLegFunc Inbound |> getCarrierList
    in
        List.filter
            (\carrier ->
                List.member carrier.id <|
                    (outboundCarriers ++ inboundCarriers)
            )
            fullFlightData.carriers


getCarrierFromSegment : List Carrier -> Segment -> Maybe Carrier
getCarrierFromSegment carriers flightSegment =
    List.head <|
        List.filter
            (\carrier -> carrier.id == flightSegment.carrier)
            carriers


getLeg : List Leg -> Itinerary -> Direction -> Maybe Leg
getLeg legs itinerary direction =
    let
        needleId =
            case direction of
                Inbound ->
                    itinerary.inboundLegId

                Outbound ->
                    itinerary.outboundLegId
    in
        List.head <|
            List.filter
                (\leg -> leg.id == needleId)
                legs


getPlace : List Place -> Int -> Maybe Place
getPlace places placeId =
    let
        filterPlace =
            \place ->
                case place of
                    AirportTag place ->
                        place.placeId == placeId

                    CityTag place ->
                        place.placeId == placeId

                    CountryTag place ->
                        place.placeId == placeId
    in
        List.head <|
            List.filter
                filterPlace
                places
