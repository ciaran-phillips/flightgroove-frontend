module UIComponents.Filters.DateField exposing (..)

import Date exposing (Date, Day(..), day, dayOfWeek, month, year)
import DatePicker exposing (defaultSettings)
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


getInboundDate : Model -> Maybe Date
getInboundDate model =
    model.inboundDate


getOutboundDate : Model -> Maybe Date
getOutboundDate model =
    model.outboundDate
