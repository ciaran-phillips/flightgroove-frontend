port module UIComponents.Map exposing (..)

import Html exposing (..)
import Html.App
import Html.Attributes exposing (id, class)


type Msg
    = SetupMap
    | MapResponse Bool


type alias Model =
    { mapActive : Bool }


initialModel : Model
initialModel =
    { mapActive = False }


initialCmd : Cmd Msg
initialCmd =
    map mapId


port map : String -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetupMap ->
            ( model, map mapId )

        MapResponse response ->
            ( { model | mapActive = response }, Cmd.none )


view : Model -> Html Msg
view model =
    div [ class "map-wrapper" ]
        [ div [ id "map" ] [] ]


mapId : String
mapId =
    "map"



-- subscriptions


port mapCallback : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    mapCallback MapResponse
