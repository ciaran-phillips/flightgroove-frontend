module Explorer.FlightSearch.FlightSearchView exposing (..)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, href, rel, target)
import Material
import Dict
import String
import Material.Tabs as Tabs
import Material.Spinner as Loading


-- Custom Modules

import Explorer.FlightSearch.FlightSearchModel as FlightSearchModel
    exposing
        ( FlightSearchModel
        , FlightsForOrigin(..)
        , OriginFlights
        )
import Explorer.Messages exposing (Msg(FlightSearchTag, Mdl))
import Explorer.FlightSearch.FlightSearchMessages exposing (FlightSearchMsg(..))
import API.Calls as API
import API.Types.LivePricing as LivePricingTypes
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
        [ Tabs.label []
            [ i [ class "material-icons" ] [ text "flight" ]
            , text <| "Flights from " ++ formatName firstOriginFlights.origin
            ]
        , Tabs.label []
            [ i [ class "material-icons" ] [ text "flight" ]
            , text <| "Flights from " ++ formatName secondOriginFlights.origin
            ]
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


formatName : String -> String
formatName originName =
    String.split "-" originName
        |> List.head
        |> Maybe.withDefault originName


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
            [ displayPrice sortedPriceOptions fullFlightData itinerary
            , displayItineraryDetails fullFlightData itinerary
            , displayBookingLink sortedPriceOptions
            ]


displayPrice : List PricingOption -> PollLivePricingResponse -> Itinerary -> Html Msg
displayPrice pricingOptions fullFlightData itinerary =
    let
        priceDisplay =
            case (List.head pricingOptions) of
                Nothing ->
                    text "No price found"

                Just pricingOption ->
                    text <| formatPrice <| toString pricingOption.price
    in
        div [ class "flight-result__price mdl-cell mdl-cell--2-col" ]
            [ priceDisplay, displayCarrier fullFlightData itinerary ]


formatPrice : String -> String
formatPrice price =
    let
        parts =
            String.split "." price
    in
        case parts of
            [] ->
                price

            [ x ] ->
                "€" ++ x ++ ".00"

            [ x, xs ] ->
                "€" ++ x ++ "." ++ String.slice 0 2 xs

            x :: xs :: _ ->
                "€" ++ x ++ "." ++ String.slice 0 2 xs


displayCarrier : PollLivePricingResponse -> Itinerary -> Html Msg
displayCarrier fullFlightData itinerary =
    let
        carriers =
            LivePricingTypes.getCarriersFromItinerary fullFlightData itinerary

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
        div [ class "flight-result__carrier" ]
            [ carrierText ]


displayItineraryDetails : PollLivePricingResponse -> Itinerary -> Html Msg
displayItineraryDetails fullFlightData itinerary =
    let
        getLeg =
            LivePricingTypes.getLeg fullFlightData.legs itinerary

        outboundLeg =
            getLeg LivePricingTypes.Outbound

        inboundLeg =
            getLeg LivePricingTypes.Inbound
    in
        div [ class "flight-result__details mdl-cell--7-col" ]
            [ table []
                [ displayLegDetails fullFlightData.places outboundLeg
                , displayLegDetails fullFlightData.places inboundLeg
                ]
            ]


displayLegDetails : List LivePricingTypes.Place -> Maybe LivePricingTypes.Leg -> Html Msg
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


displayAirport : List LivePricingTypes.Place -> Int -> Html Msg
displayAirport places placeId =
    let
        place =
            LivePricingTypes.getPlace places placeId
    in
        case place of
            Nothing ->
                text ""

            Just (LivePricingTypes.AirportTag airport) ->
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
        div [ class "flight-result__action mdl-cell mdl-cell--2-col mdl-cell--4-col-phone mdl-cell--8-col-tablet" ]
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
    String.slice 11 16 dateString


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
