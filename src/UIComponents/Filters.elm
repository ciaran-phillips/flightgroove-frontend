module UIComponents.Filters exposing (..)

import UIComponents.Filters.Location as Location
import Html.App
import Html exposing (Html)


type alias Model =
    { origin : Location.Model
    }


type Msg
    = OriginMsg Location.Msg


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { origin = Location.model
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OriginMsg msg ->
            let
                ( newModel, newCmd ) =
                    Location.update msg model.origin
            in
                ( { model | origin = newModel }, Cmd.map OriginMsg newCmd )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map OriginMsg <|
        Location.subscriptions model.origin


getCriteria : Model -> String
getCriteria model =
    Location.getSelectedLocation model.origin


view : Model -> Html Msg
view model =
    Html.App.map OriginMsg <|
        Location.view model.origin
