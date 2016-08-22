module UIComponents.Filters exposing (..)

import Material exposing (..)
import Material.Textfield as Textfield
import Html exposing (..)


type alias Model =
    { mdl : Material.Model
    , airport : String
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { mdl = Material.model
    , airport = ""
    }


type Msg
    = Mdl (Material.Msg Msg)
    | ChangeAirport String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeAirport txt ->
            ( { model | airport = txt }, Cmd.none )

        Mdl msg' ->
            Material.update msg' model


view : Model -> Html Msg
view model =
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
