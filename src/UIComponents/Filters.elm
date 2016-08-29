module UIComponents.Filters exposing (..)

import Material exposing (..)
import Material.Textfield as Textfield
import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Autocomplete


type alias Model =
    { mdl : Material.Model
    , airport : String
    , autocomplete : Autocomplete.Autocomplete
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { mdl = Material.model
    , airport = ""
    , autocomplete = Autocomplete.init [ "Dublin", "Paris", "Dubrovnik", "Poznan", "Rome", "Rennes", "London", "Lyon", "Liverpool" ]
    }


type Msg
    = Mdl (Material.Msg Msg)
    | ChangeAirport String
    | AutocompleteMsg Autocomplete.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeAirport txt ->
            ( { model | airport = txt }, Cmd.none )

        Mdl msg' ->
            Material.update msg' model

        AutocompleteMsg msg ->
            let
                ( newModel, status ) =
                    Autocomplete.update msg model.autocomplete
            in
                ( { model | autocomplete = newModel }, Cmd.none )


viewAirportSelector : Model -> Html Msg
viewAirportSelector model =
    div []
        [ Textfield.render Mdl
            [ 8 ]
            model.mdl
            [ Textfield.label
                "Airport"
            , Textfield.onInput ChangeAirport
            , Textfield.autofocus
            , Textfield.floatingLabel
            ]
        , div [] [ text model.airport ]
        ]


viewAutocomplete : Model -> Html Msg
viewAutocomplete model =
    Html.App.map AutocompleteMsg <|
        div [ class "dropdown-container" ]
            [ Autocomplete.view model.autocomplete ]
