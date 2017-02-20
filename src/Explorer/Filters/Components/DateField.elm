module Explorer.Filters.Components.DateField exposing (..)

import Date exposing (Date, Day(..), Month(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)
import String
import Html exposing (Html, select, text, option, map)
import Html.Attributes exposing (value, class, selected)
import Json.Decode
import Html.Events
import Material
import Material.Toggles as Toggles
import Array
import Task
import Result


type alias Model =
    { isReturn : Bool
    , outboundDate : Maybe Date
    , outboundPicker : DatePicker.DatePicker
    , inboundDate : Maybe Date
    , inboundPicker : DatePicker.DatePicker
    , outboundMonth : PartialDate
    , inboundMonth : PartialDate
    , useExactDates : Bool
    , mdl : Material.Model
    , currentDate : Date.Date
    }


type Msg
    = OutboundMsg DatePicker.Msg
    | InboundMsg DatePicker.Msg
    | SelectOutboundMonth String
    | SelectInboundMonth String
    | MaterialMsg (Material.Msg Msg)
    | ToggleExactDates
    | GetCurrentDateFailure Result.Result
    | GetCurrentDateSuccess Date


type alias PartialDate =
    { year : Int
    , month : Month
    }


init : String -> ( Model, Cmd Msg )
init currentMonth =
    let
        ( datePickerModel, datePickerFx ) =
            DatePicker.init DatePicker.defaultSettings

        initialMonth =
            Maybe.withDefault defaultDate <|
                decodeMonthSelection currentMonth
    in
        ( { isReturn = True
          , outboundDate = Nothing
          , outboundPicker = datePickerModel
          , inboundDate = Nothing
          , inboundPicker = datePickerModel
          , outboundMonth = initialMonth
          , inboundMonth = initialMonth
          , useExactDates = False
          , mdl = Material.model
          , currentDate = Date.fromTime 0
          }
        , getCurrentDate
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MaterialMsg msg ->
            Material.update msg model

        ToggleExactDates ->
            ( { model | useExactDates = not model.useExactDates }, Cmd.none )

        OutboundMsg msg ->
            let
                ( newModel, newCmd, newDate ) =
                    DatePicker.update msg model.outboundPicker

                outboundDate =
                    case newDate of
                        Nothing ->
                            model.outboundDate

                        Just date ->
                            newDate

                -- we need to re-initialize the inbound picker to properly restrict allowed dates
                defaultSettings =
                    DatePicker.defaultSettings

                ( newInboundDate, boundingFunc ) =
                    limitInboundDate model.currentDate model.inboundDate outboundDate

                ( inboundPickerModel, inboundPickerCmd ) =
                    DatePicker.init
                        { defaultSettings
                            | pickedDate = Debug.log "limiting inbound date to " newInboundDate
                            , isDisabled = boundingFunc
                        }
            in
                ( { model
                    | outboundDate = outboundDate
                    , outboundPicker = newModel
                    , inboundPicker = inboundPickerModel
                    , inboundDate = newInboundDate
                  }
                , Cmd.batch [ Cmd.map OutboundMsg newCmd, Cmd.map InboundMsg inboundPickerCmd ]
                )

        InboundMsg msg ->
            let
                ( newModel, newCmd, newDate ) =
                    DatePicker.update msg model.inboundPicker

                date =
                    case newDate of
                        Nothing ->
                            model.inboundDate

                        Just date' ->
                            Just date'
            in
                ( { model | inboundDate = date, inboundPicker = newModel }
                , Cmd.map InboundMsg newCmd
                )

        GetCurrentDateSuccess date ->
            let
                defaultSettings =
                    DatePicker.defaultSettings

                -- Create a version of the DatePicker that's already set to the current date, and
                -- override the ones we've already set in our model (while we were waiting for this Cmd to finish)
                initialOutboundDate =
                    Just <| addDaysToDate 1 date

                ( outboundPickerModel, outboundPickerCmd ) =
                    DatePicker.init { defaultSettings | pickedDate = initialOutboundDate, isDisabled = earlierThan date }

                initialInboundDate =
                    Just <| addDaysToDate 4 date

                ( inboundPickerModel, inboundPickerCmd ) =
                    DatePicker.init
                        { defaultSettings
                            | pickedDate = initialInboundDate
                            , isDisabled = earlierThan <| addDaysToDate 1 date
                        }
            in
                ( { model
                    | currentDate = date
                    , outboundPicker = outboundPickerModel
                    , inboundPicker = inboundPickerModel
                    , inboundDate = initialInboundDate
                    , outboundDate = initialOutboundDate
                  }
                , Cmd.batch
                    [ Cmd.map OutboundMsg outboundPickerCmd
                    , Cmd.map InboundMsg inboundPickerCmd
                    ]
                )

        GetCurrentDateFailure err ->
            model ! []

        SelectOutboundMonth month ->
            let
                newOutbound =
                    Maybe.withDefault defaultDate <| decodeMonthSelection month

                newInbound =
                    limitInboundMonth newOutbound model.inboundMonth
            in
                { model | outboundMonth = newOutbound, inboundMonth = newInbound } ! []

        SelectInboundMonth month ->
            let
                partialDate =
                    Maybe.withDefault defaultDate <| decodeMonthSelection month
            in
                { model | inboundMonth = partialDate } ! []


limitInboundMonth : PartialDate -> PartialDate -> PartialDate
limitInboundMonth newOutboundMonth inboundMonth =
    if earlierMonthThan newOutboundMonth inboundMonth then
        Debug.log "resetting inbound month" newOutboundMonth
    else
        inboundMonth


limitInboundDate : Date -> Maybe Date -> Maybe Date -> ( Maybe Date, Date -> Bool )
limitInboundDate currentDate currentInbound outboundDate =
    case ( currentInbound, outboundDate ) of
        ( Just inbound, Just outbound ) ->
            if earlierThan outbound inbound then
                ( Just <| addDaysToDate 1 outbound, earlierThan outbound )
            else
                ( Just inbound, earlierThan outbound )

        _ ->
            ( currentInbound, earlierThan currentDate )


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    Html.Events.on "change" (Json.Decode.map msg Html.Events.targetValue)


viewToggle : Model -> Html Msg
viewToggle model =
    Toggles.switch MaterialMsg
        [ 0 ]
        model.mdl
        [ Toggles.onClick ToggleExactDates
        , Toggles.ripple
        , Toggles.value model.useExactDates
        ]
        [ text "search specific dates" ]


viewOutbound : Model -> Html Msg
viewOutbound model =
    let
        currentPartialDate =
            PartialDate (Date.year model.currentDate) (Date.month model.currentDate)
    in
        if model.useExactDates then
            DatePicker.view model.outboundPicker
                |> Html.map OutboundMsg
        else
            Html.select [ onChange SelectOutboundMonth ] <| getMonthOptions model currentPartialDate model.outboundMonth


viewInbound : Model -> Html Msg
viewInbound model =
    if model.useExactDates then
        DatePicker.view model.inboundPicker
            |> Html.map InboundMsg
    else
        Html.select [ onChange SelectInboundMonth ] <|
            getMonthOptions model model.outboundMonth model.inboundMonth


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


getInboundDate : Model -> String
getInboundDate model =
    if model.useExactDates then
        formatDate model.inboundDate
    else
        formatMonth model.inboundMonth.year model.inboundMonth.month


getOutboundDate : Model -> String
getOutboundDate model =
    if model.useExactDates then
        formatDate model.outboundDate
    else
        formatMonth model.outboundMonth.year model.outboundMonth.month


formatDate : Maybe Date -> String
formatDate date =
    case date of
        Nothing ->
            "2017-10"

        Just date ->
            (toString <| Date.year date)
                ++ "-"
                ++ (padDigits <| toString <| getMonthNumber <| Date.month date)
                ++ "-"
                ++ (padDigits <| toString <| Date.day date)


formatMonth : Int -> Month -> String
formatMonth year month =
    let
        monthNumber =
            String.pad 2 '0' <|
                toString <|
                    getMonthNumber month
    in
        toString year
            ++ "-"
            ++ monthNumber


decodeMonthSelection : String -> Maybe PartialDate
decodeMonthSelection yearAndMonth =
    let
        year =
            Result.withDefault 0 <| String.toInt <| String.slice 0 4 yearAndMonth

        monthNum =
            Result.withDefault 1 <| String.toInt <| String.slice 5 7 yearAndMonth

        month =
            List.head <|
                List.filter (\( i, month' ) -> i == monthNum)
                    listOfMonths
    in
        case month of
            Nothing ->
                Nothing

            Just ( index, m ) ->
                Just <| PartialDate year m


getMonthOptions : Model -> PartialDate -> PartialDate -> List (Html Msg)
getMonthOptions model earliestMonth selectedMonth =
    let
        currentDate =
            model.currentDate

        currentMonth =
            Date.month currentDate

        currentMonthNumber =
            getMonthNumber currentMonth

        currentYear =
            Date.year currentDate

        nextYear =
            currentYear + 1

        filterTooEarly =
            \year ( monthNumber, month ) ->
                if year < earliestMonth.year then
                    False
                else if year > earliestMonth.year then
                    True
                else
                    monthNumber >= getMonthNumber earliestMonth.month
    in
        (List.map (formatOption currentYear selectedMonth) <|
            List.filter (filterTooEarly currentYear) <|
                List.drop (currentMonthNumber - 1) listOfMonths
        )
            ++ (List.map (formatOption nextYear selectedMonth) <|
                    List.filter (filterTooEarly nextYear) <|
                        List.take (currentMonthNumber) listOfMonths
               )


formatOption : Int -> PartialDate -> ( Int, Month ) -> Html Msg
formatOption year selectedMonth ( monthNumber, month ) =
    let
        isSelected =
            selectedMonth.month == month && selectedMonth.year == year
    in
        Html.option [ selected isSelected, value <| toString year ++ "-" ++ toString monthNumber ] [ text <| toString month ++ " " ++ toString year ]


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
                listOfMonths


listOfMonths : List ( Int, Month )
listOfMonths =
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


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform GetCurrentDateFailure GetCurrentDateSuccess Date.now


addDaysToDate : Int -> Date.Date -> Date.Date
addDaysToDate numDays date =
    let
        -- Elm works on milliseconds, so multiply by 1000
        seconds =
            numDays * 86400 * 1000
    in
        date |> Date.toTime |> (+) seconds |> Date.fromTime


earlierThan : Date -> Date -> Bool
earlierThan earlyDate dateToTest =
    Date.toTime dateToTest < Date.toTime earlyDate


earlierMonthThan : PartialDate -> PartialDate -> Bool
earlierMonthThan earlyDate dateToTest =
    let
        earlyMonthIndex =
            getMonthNumber earlyDate.month

        monthToTestIndex =
            getMonthNumber dateToTest.month

        earlyYear =
            earlyDate.year

        yearToTest =
            dateToTest.year
    in
        if yearToTest < earlyYear then
            True
        else if yearToTest > earlyYear then
            False
        else
            (monthToTestIndex < earlyMonthIndex)


defaultDate : PartialDate
defaultDate =
    PartialDate 2017 Mar
