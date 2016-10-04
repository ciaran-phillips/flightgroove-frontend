module UIComponents.Filters exposing (..)

import UIComponents.Filters.Location as Location
import UIComponents.Filters.DateField as DateField
import UIComponents.Types exposing (FilterCriteria)
import Html.App
import Html exposing (Html, div)


type alias Model =
    { origin : Location.Model
    , dateField : DateField.Model
    }


type Msg
    = OriginMsg Location.Msg
    | DateFieldMsg DateField.Msg


init : ( Model, Cmd Msg )
init =
    let
        ( dateFieldModel, dateFieldCmd ) =
            DateField.init
    in
        ( { origin = Location.model
          , dateField = dateFieldModel
          }
        , Cmd.map DateFieldMsg dateFieldCmd
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OriginMsg msg ->
            let
                ( newModel, newCmd ) =
                    Location.update msg model.origin
            in
                ( { model | origin = newModel }, Cmd.map OriginMsg newCmd )

        DateFieldMsg msg ->
            let
                ( newModel, newCmd ) =
                    DateField.update msg model.dateField
            in
                ( { model | dateField = newModel }
                , Cmd.map DateFieldMsg newCmd
                )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map OriginMsg <|
            Location.subscriptions model.origin
        , Sub.map DateFieldMsg <|
            DateField.subscriptions model.dateField
        ]


getCriteria : Model -> FilterCriteria
getCriteria model =
    let
        locationId =
            case Location.getSelectedLocation model.origin of
                Nothing ->
                    ""

                Just location ->
                    location
    in
        FilterCriteria
            (locationId)
            (DateField.getInboundDate model.dateField)
            (DateField.getOutboundDate model.dateField)


viewOriginSearch : Model -> Html Msg
viewOriginSearch model =
    div []
        [ Html.App.map OriginMsg <|
            Location.view model.origin
        ]


viewOutboundDate : Model -> Html Msg
viewOutboundDate model =
    Html.App.map DateFieldMsg <|
        DateField.viewOutbound model.dateField


viewInboundDate : Model -> Html Msg
viewInboundDate model =
    Html.App.map DateFieldMsg <|
        DateField.viewInbound model.dateField
