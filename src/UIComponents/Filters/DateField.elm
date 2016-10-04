module UIComponents.Filters.DateField exposing (..)

import Date exposing (Date, Day(..), Month(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)
import String
import Html exposing (Html, select, text, option)
import Html.Attributes exposing (value)
import Json.Decode
import Html.Events
import Html.App
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
    , outboundMonth : Month
    , inboundMonth : Month
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
          , outboundMonth = Nov
          , inboundMonth = Nov
          , useExactDates = False
          , mdl = Material.model
          , currentDate = Date.fromTime 0
          }
        , Cmd.batch
            [ Cmd.map OutboundMsg datePickerFx
            , Cmd.map InboundMsg datePickerFx
            , getCurrentDate
            ]
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

        GetCurrentDateSuccess date ->
            ( { model | currentDate = date }, Cmd.none )

        GetCurrentDateFailure err ->
            model ! []

        SelectOutboundMonth monthNumber ->
            let
                num =
                    Result.withDefault 11 <| String.toInt monthNumber

                ( ind, month ) =
                    Maybe.withDefault ( 11, Nov ) <|
                        List.head <|
                            List.filter (\( i, m ) -> i == num) listOfMonths
            in
                { model | outboundMonth = month } ! []

        SelectInboundMonth monthNumber ->
            let
                num =
                    Result.withDefault 11 <| String.toInt monthNumber

                ( ind, month ) =
                    Maybe.withDefault ( 11, Nov ) <|
                        List.head <|
                            List.filter (\( i, m ) -> i == num) listOfMonths
            in
                { model | inboundMonth = month } ! []


onChange : (String -> msg) -> Html.Attribute msg
onChange msg =
    Html.Events.on "change" (Json.Decode.map msg Html.Events.targetValue)


viewToggle : Model -> Html Msg
viewToggle model =
    Toggles.checkbox MaterialMsg
        [ 0 ]
        model.mdl
        [ Toggles.onClick ToggleExactDates
        , Toggles.ripple
        , Toggles.value model.useExactDates
        ]
        [ text "Search specific dates" ]


viewOutbound : Model -> Html Msg
viewOutbound model =
    if model.useExactDates then
        DatePicker.view model.outboundPicker
            |> Html.App.map OutboundMsg
    else
        Html.select [ onChange SelectOutboundMonth ] <| getMonthOptions model model.outboundMonth


viewInbound : Model -> Html Msg
viewInbound model =
    if model.useExactDates then
        DatePicker.view model.inboundPicker
            |> Html.App.map InboundMsg
    else
        Html.select [ onChange SelectInboundMonth ] <| getMonthOptions model model.inboundMonth


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
            "2016-10"

        Just date ->
            (toString <| Date.year date)
                ++ "-"
                ++ (padDigits <| toString <| getMonthNumber <| Date.month date)
                ++ "-"
                ++ (padDigits <| toString <| Date.day date)


getMonthOptions : Model -> Month -> List (Html Msg)
getMonthOptions model selectedMonth =
    let
        currentDate =
            model.currentDate

        currentMonth =
            Date.month currentDate

        currentMonthNumber =
            getMonthNumber currentMonth

        currentYear =
            Date.year currentDate
    in
        List.map (formatOption currentYear) <| List.drop (currentMonthNumber - 1) listOfMonths


formatOption : Int -> ( Int, Month ) -> Html Msg
formatOption year ( monthNumber, month ) =
    Html.option [ value <| toString monthNumber ] [ text <| toString month ++ " " ++ toString year ]


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
