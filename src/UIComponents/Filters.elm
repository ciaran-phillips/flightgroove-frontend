module UIComponents.Filters exposing (..)

import UIComponents.Filters.Location as Location
import UIComponents.Filters.DateField as DateField
import UIComponents.Types exposing (FilterCriteria)
import Html.App
import Html exposing (Html, div, text, button, label, i)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class, classList)
import Material
import Material.Toggles as Toggles


type alias Model =
    { firstOrigin : Location.Model
    , secondOrigin : ExtraOrigin
    , dropdownShown : Bool
    , dateField : DateField.Model
    , mdl : Material.Model
    }


type ExtraOrigin
    = Disabled Location.Model
    | Enabled Location.Model


type Msg
    = FirstOriginMsg Location.Msg
    | SecondOriginMsg Location.Msg
    | ToggleSecondOrigin
    | DateFieldMsg DateField.Msg
    | MaterialMsg (Material.Msg Msg)
    | ToggleOriginDropdown


init : ( Model, Cmd Msg )
init =
    let
        ( dateFieldModel, dateFieldCmd ) =
            DateField.init
    in
        ( { firstOrigin = Location.model
          , secondOrigin = Disabled Location.model
          , dateField = dateFieldModel
          , dropdownShown = False
          , mdl = Material.model
          }
        , Cmd.batch
            [ Cmd.map DateFieldMsg dateFieldCmd
            , Cmd.map FirstOriginMsg Location.initialCmd
            ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FirstOriginMsg msg ->
            let
                ( newModel, newCmd ) =
                    Location.update msg model.firstOrigin
            in
                ( { model | firstOrigin = newModel }, Cmd.map FirstOriginMsg newCmd )

        SecondOriginMsg msg ->
            let
                ( newModel, newCmd ) =
                    case model.secondOrigin of
                        Enabled secondOrigin ->
                            Location.update msg secondOrigin
                                |> (\( m, c ) -> ( Enabled m, c ))

                        Disabled a ->
                            ( Disabled a, Cmd.none )
            in
                ( { model | secondOrigin = newModel }, Cmd.map SecondOriginMsg newCmd )

        ToggleSecondOrigin ->
            let
                newModel =
                    case model.secondOrigin of
                        Enabled origin ->
                            Disabled origin

                        Disabled origin ->
                            Enabled origin
            in
                ( { model | secondOrigin = newModel }, Cmd.none )

        ToggleOriginDropdown ->
            ( { model | dropdownShown = not model.dropdownShown }, Cmd.none )

        DateFieldMsg msg ->
            let
                ( newModel, newCmd ) =
                    DateField.update msg model.dateField
            in
                ( { model | dateField = newModel }
                , Cmd.map DateFieldMsg newCmd
                )

        MaterialMsg msg ->
            Material.update msg model


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        secondOrigin =
            case model.secondOrigin of
                Enabled origin ->
                    origin

                Disabled origin ->
                    origin
    in
        Sub.batch
            [ Sub.map FirstOriginMsg <|
                Location.subscriptions model.firstOrigin
            , Sub.map SecondOriginMsg <|
                Location.subscriptions secondOrigin
            , Sub.map DateFieldMsg <|
                DateField.subscriptions model.dateField
            ]


getCriteria : Model -> Maybe FilterCriteria
getCriteria model =
    let
        locationId =
            Location.getSelectedLocation model.firstOrigin
    in
        case locationId of
            Nothing ->
                Nothing

            Just location ->
                Just <|
                    FilterCriteria
                        (location)
                        (DateField.getOutboundDate model.dateField)
                        (DateField.getInboundDate model.dateField)


multipleOriginsEnabled : Model -> Bool
multipleOriginsEnabled model =
    case model.secondOrigin of
        Disabled a ->
            False

        Enabled a ->
            True


viewOriginSearch : Model -> Html Msg
viewOriginSearch model =
    case model.secondOrigin of
        Disabled a ->
            div []
                [ label [] [ text "Departing from" ]
                , viewFirstOriginSearch model
                ]

        Enabled origin ->
            div []
                [ div [ onClick ToggleOriginDropdown, class "origin-dropdown__airports" ]
                    [ div []
                        [ text <| "1: " ++ Location.viewAirportName model.firstOrigin
                        , i [ class "material-icons" ] [ text "expand_more" ]
                        ]
                    , div []
                        [ text <| "2: " ++ Location.viewAirportName origin
                        , i [ class "material-icons" ] [ text "expand_more" ]
                        ]
                    ]
                , dropdownWrapper model.dropdownShown <|
                    div []
                        [ div []
                            [ label [] [ text "Traveller 1 departing from" ]
                            , viewFirstOriginSearch model
                            ]
                        , div []
                            [ label [] [ text "Traveller 2 departing from" ]
                            , viewSecondOrigin origin
                            ]
                        ]
                ]


dropdownWrapper : Bool -> Html Msg -> Html Msg
dropdownWrapper active content =
    div [ classList [ ( "origin-dropdown", True ), ( "is-active", active ) ] ]
        [ div [ class "origin-dropdown__content" ]
            [ div [ class "origin-dropdown__triangle" ] []
            , content
            ]
        ]


viewFirstOriginSearch : Model -> Html Msg
viewFirstOriginSearch model =
    div [ class "form-control" ]
        [ Html.App.map FirstOriginMsg <|
            Location.view model.firstOrigin
        ]


viewSecondOrigin : Location.Model -> Html Msg
viewSecondOrigin origin =
    div [ class "form-control" ]
        [ Html.App.map SecondOriginMsg <|
            Location.view origin
        ]


viewOriginsToggle : Model -> Html Msg
viewOriginsToggle model =
    let
        isEnabled =
            case model.secondOrigin of
                Disabled a ->
                    False

                Enabled a ->
                    True
    in
        Toggles.switch MaterialMsg
            [ 0 ]
            model.mdl
            [ Toggles.onClick ToggleSecondOrigin
            , Toggles.ripple
            , Toggles.value isEnabled
            ]
            [ text "enable multiple origins" ]


viewOutboundDate : Model -> Html Msg
viewOutboundDate model =
    Html.App.map DateFieldMsg <|
        DateField.viewOutbound model.dateField


viewInboundDate : Model -> Html Msg
viewInboundDate model =
    Html.App.map DateFieldMsg <|
        DateField.viewInbound model.dateField


viewToggle : Model -> Html Msg
viewToggle model =
    Html.App.map DateFieldMsg <|
        DateField.viewToggle model.dateField
