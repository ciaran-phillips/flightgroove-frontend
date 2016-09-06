module UIComponents.Filters.DateField exposing (..)

import Date exposing (Date, Day(..), Month(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)
import String
import Html exposing (Html)
import Html.App


type alias Model =
    { isReturn : Bool
    , outboundDate : Maybe Date
    , outboundPicker : DatePicker.DatePicker
    , inboundDate : Maybe Date
    , inboundPicker : DatePicker.DatePicker
    }


type Msg
    = OutboundMsg DatePicker.Msg
    | InboundMsg DatePicker.Msg


init : ( Model, Cmd Msg )
init =
    let
        ( datePickerModel, datePickerFx ) =
            DatePicker.init DatePicker.defaultSettings
    in
        ( { isReturn = True
          , outboundDate = Nothing
          , outboundPicker = datePickerModel
          , inboundDate = Nothing
          , inboundPicker = datePickerModel
          }
        , Cmd.batch
            [ Cmd.map OutboundMsg datePickerFx
            , Cmd.map InboundMsg datePickerFx
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OutboundMsg msg ->
            let
                ( newModel, newCmd, newDate ) =
                    DatePicker.update msg model.outboundPicker

                date =
                    case newDate of
                        Nothing ->
                            model.outboundDate

                        date ->
                            date
            in
                ( { model | outboundDate = date, outboundPicker = newModel }
                , Cmd.map OutboundMsg newCmd
                )

        InboundMsg msg ->
            let
                ( newModel, newCmd, newDate ) =
                    DatePicker.update msg model.inboundPicker

                date =
                    case newDate of
                        Nothing ->
                            model.inboundDate

                        date ->
                            date
            in
                ( { model | inboundDate = date, inboundPicker = newModel }
                , Cmd.map InboundMsg newCmd
                )


viewOutbound : Model -> Html Msg
viewOutbound model =
    DatePicker.view model.outboundPicker
        |> Html.App.map OutboundMsg


viewInbound : Model -> Html Msg
viewInbound model =
    DatePicker.view model.inboundPicker
        |> Html.App.map InboundMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getInboundDate : Model -> String
getInboundDate model =
    formatDate model.inboundDate


getOutboundDate : Model -> String
getOutboundDate model =
    formatDate model.outboundDate


formatDate : Maybe Date -> String
formatDate date =
    case date of
        Nothing ->
            "2016-09"

        Just date ->
            (toString <| Date.year date)
                ++ "-"
                ++ (padDigits <| toString <| getMonthNumber <| Date.month date)
                ++ "-"
                ++ (padDigits <| toString <| Date.day date)


getMonthNumber : Date.Month -> Int
getMonthNumber month =
    let
        monthTuple =
            getMonth month
    in
        case monthTuple of
            Nothing ->
                1

            Just ( index, month ) ->
                index


getMonth : Date.Month -> Maybe ( Int, Date.Month )
getMonth month =
    let
        filterFunc =
            \n ->
                let
                    ( i, m ) =
                        n
                in
                    m == month
    in
        List.head <|
            List.filter filterFunc
                [ ( 1, Jan )
                , ( 2, Feb )
                , ( 3, Mar )
                , ( 4, Apr )
                , ( 5, May )
                , ( 6, Jun )
                , ( 7, Jul )
                , ( 8, Aug )
                , ( 9, Sep )
                , ( 10, Oct )
                , ( 11, Nov )
                , ( 12, Dec )
                ]


padDigits : String -> String
padDigits txt =
    if String.length txt == 1 then
        "0" ++ txt
    else
        txt
