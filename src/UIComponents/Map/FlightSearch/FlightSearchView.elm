module UIComponents.Map.FlightSearch.FlightSearchView exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, href, rel, target)
import Material
import Dict
import String
import Material.Tabs as Tabs
import Material.Spinner as Loading


-- Custom Modules

import UIComponents.Map.FlightSearch.FlightSearchModel as FlightSearchModel
    exposing
        ( FlightSearchModel
        , FlightsForOrigin(..)
        , OriginFlights
        )
import UIComponents.Map.Messages exposing (Msg(FlightSearchTag, Mdl))
import UIComponents.Map.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg(..))
import API.PollLivePricing as PollLivePricing
    exposing
        ( PollLivePricingResponse
        , Itinerary
        , PricingOption
        , Place
        )


view : Material.Model -> FlightSearchModel -> Html Msg
view mdl model =
    div []
        [ div [ class "search-overlay__background" ] []
        , div [ class "search-overlay__content" ]
            [ div [ class "search-overlay__header" ]
                [ div [ class "location-background" ] []
                , div [ class "background-overlay" ] []
                , closeButton
                , h3 [ class "search-overlay__title" ]
                    [ text <| "Flights to " ++ model.destination ]
                ]
            , viewPopupBody mdl model
            ]
        ]


viewPopupBody : Material.Model -> FlightSearchModel -> Html Msg
viewPopupBody mdl model =
    case model.flightsForOrigin of
        SingleOrigin originAndFlight ->
            viewContent originAndFlight

        MultipleOrigins originAndFlight secondOriginAndFlight ->
            viewTabs mdl model originAndFlight secondOriginAndFlight


viewTabs : Material.Model -> FlightSearchModel -> OriginFlights -> OriginFlights -> Html Msg
viewTabs mdl model firstOriginFlights secondOriginFlights =
    Tabs.render Mdl
        [ 2 ]
        mdl
        [ Tabs.activeTab model.activeTab
        , Tabs.onSelectTab <| FlightSearchTag << SelectFlightsTab
        ]
        [ Tabs.label [] [ text <| "Flights from " ++ firstOriginFlights.origin ]
        , Tabs.label [] [ text <| "Flights from " ++ secondOriginFlights.origin ]
        ]
        [ case model.activeTab of
            0 ->
                div [ class "sidebar--block" ] [ viewContent firstOriginFlights ]

            _ ->
                div [ class "sidebar--block" ] [ viewContent secondOriginFlights ]
        ]


viewContent : OriginFlights -> Html Msg
viewContent flightData =
    div [ class "search-overlay__body flight-search" ]
        [ div [ class "flight-search__filters" ] []
        , div [ class "flight-search__list" ]
            [ ul [ class "unstyled" ] <|
                displayFlights flightData
            ]
        ]


closeButton : Html Msg
closeButton =
    div [ class "clearing" ]
        [ button
            [ onClick <| FlightSearchTag CloseFlightSearch, class "mdl-button flight-search__close" ]
            [ text "Close Flight Search "
            , i [ class "material-icons" ] [ text "clear" ]
            ]
        ]


displayFlights : OriginFlights -> List (Html Msg)
displayFlights originFlights =
    case originFlights.flightData of
        Nothing ->
            [ div [ class "loading-spinner" ]
                [ Loading.spinner
                    [ Loading.active True
                    , Loading.singleColor True
                    ]
                ]
            ]

        Just data ->
            List.map (displayFlight data) data.itineraries


displayFlight : PollLivePricingResponse -> Itinerary -> Html Msg
displayFlight fullFlightData itinerary =
    let
        sortedPriceOptions =
            List.sortBy (.price) itinerary.pricingOptions
    in
        li [ class "flight-result mdl-grid" ]
            [ displayPrice sortedPriceOptions
            , displayCarrier fullFlightData itinerary
            , displayItineraryDetails fullFlightData itinerary
            , displayBookingLink sortedPriceOptions
            ]


displayPrice : List PricingOption -> Html Msg
displayPrice pricingOptions =
    let
        priceDisplay =
            case (List.head pricingOptions) of
                Nothing ->
                    text "No price found"

                Just pricingOption ->
                    text <| toString pricingOption.price
    in
        div [ class "flight-result__price mdl-cell mdl-cell--2-col" ]
            [ priceDisplay ]


displayCarrier : PollLivePricingResponse -> Itinerary -> Html Msg
displayCarrier fullFlightData itinerary =
    let
        carriers =
            PollLivePricing.getCarriersFromItinerary fullFlightData itinerary

        carrierText =
            case carriers of
                [] ->
                    text ""

                [ carrier ] ->
                    text carrier.name

                [ firstCarrier, secondCarrier ] ->
                    text <| firstCarrier.name ++ " / " ++ secondCarrier.name

                x :: xs :: _ ->
                    text "Multiple Airlines"
    in
        div [ class "flight-result__carrier mdl-cell mdl-cell--2-col" ]
            [ carrierText ]


displayItineraryDetails : PollLivePricingResponse -> Itinerary -> Html Msg
displayItineraryDetails fullFlightData itinerary =
    let
        getLeg =
            PollLivePricing.getLeg fullFlightData.legs itinerary

        outboundLeg =
            getLeg PollLivePricing.Outbound

        inboundLeg =
            getLeg PollLivePricing.Inbound
    in
        div [ class "flight-result__details mdl-cell--6-col" ]
            [ table []
                [ displayLegDetails fullFlightData.places outboundLeg
                , displayLegDetails fullFlightData.places inboundLeg
                ]
            ]


displayLegDetails : List PollLivePricing.Place -> Maybe PollLivePricing.Leg -> Html Msg
displayLegDetails places leg =
    case leg of
        Nothing ->
            tr [] []

        Just leg ->
            tr []
                [ td [ class "flight-result__time" ]
                    [ text <| formatDate leg.departureTime ]
                , td [ class "flight-result__airport" ]
                    [ displayAirport places leg.originId ]
                , td []
                    [ i [ class "material-icons" ]
                        [ text "arrow_forward" ]
                    ]
                , td [ class "flight-result__time" ]
                    [ text <| formatDate leg.arrivalTime ]
                , td [ class "flight-result__airport" ]
                    [ displayAirport places leg.destinationId ]
                , td [ class "flight-result__duration" ]
                    [ text <| formatDuration leg.duration ]
                ]


displayAirport : List PollLivePricing.Place -> Int -> Html Msg
displayAirport places placeId =
    let
        place =
            PollLivePricing.getPlace places placeId
    in
        case place of
            Nothing ->
                text ""

            Just (PollLivePricing.AirportTag airport) ->
                text airport.name

            _ ->
                text ""


displayBookingLink : List PricingOption -> Html Msg
displayBookingLink pricingOptions =
    let
        bookingLink =
            case List.head pricingOptions of
                Nothing ->
                    ""

                Just pricingOption ->
                    pricingOption.deeplink
    in
        div [ class "flight-result__action mdl-cell mdl-cell--2-col" ]
            [ a
                [ class "mdl-button mdl-button--raised mdl-button--accent"
                , href bookingLink
                , rel "nofollow"
                , target "_blank"
                ]
                [ text "Buy Flights" ]
            ]


formatDate : String -> String
formatDate dateString =
    String.slice 11 15 dateString


formatDuration : Int -> String
formatDuration numMinutes =
    let
        hours =
            numMinutes // 60

        minutes =
            numMinutes % 60

        hoursDisplay =
            toString hours

        minutesDisplay =
            toString minutes
    in
        hoursDisplay ++ "hr " ++ minutesDisplay ++ "m"


tag : (a -> FlightSearchMsg) -> a -> Msg
tag msg =
    FlightSearchTag << msg
