port module UIComponents.Map exposing (..)

import Html exposing (..)
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)
import Http
import Task
import API.Skyscanner as API
import API.Response as Response


type Msg
    = SetupMap
    | MapResponse Bool
    | PopupResponse Bool
    | FetchData
    | FetchSuccess Response.Response
    | FetchFail Http.Error


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    }


type alias PopupDefinition =
    ( Float, Float, String )


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    }


defaultMapData : Response.Routes
defaultMapData =
    []


initialCmd : Cmd Msg
initialCmd =
    map mapId


port map : String -> Cmd msg


port popup : PopupDefinition -> Cmd msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetupMap ->
            ( model, map mapId )

        MapResponse response ->
            ( { model | mapActive = response }, Cmd.none )

        PopupResponse response ->
            let
                x =
                    Debug.log "successfully added popup" response
            in
                ( model, Cmd.none )

        FetchData ->
            ( model, getApiData )

        FetchFail error ->
            let
                x =
                    Debug.log "error is " error
            in
                ( model, Cmd.none )

        FetchSuccess response ->
            case response of
                Response.RoutesResponse routes ->
                    ( { model | mapData = routes }, createPopups routes )

                Response.LocationsResponse locations ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ div []
            [ button [ onClick FetchData ] [ text "fetch data" ] ]
        , div [ class "map-wrapper" ] [ div [ id "map" ] [] ]
        ]


mapId : String
mapId =
    "map"


getApiData : Cmd Msg
getApiData =
    Task.perform FetchFail FetchSuccess getRoutes


createPopups : Response.Routes -> Cmd Msg
createPopups routes =
    List.map popupFromRoute routes
        |> Debug.log "list of popups"
        |> Cmd.batch


popupFromRoute : Response.Route -> Cmd msg
popupFromRoute route =
    popup
        ( route.destination.longitude
        , route.destination.latitude
        , route.priceDisplay
        )


getRoutes : Task.Task Http.Error Response.Response
getRoutes =
    API.callRoutes
        { origin = "DUB-sky"
        , destination = "anywhere"
        , outboundDate = "2016-09"
        , inboundDate = "2016-09"
        }



-- subscriptions


port mapCallback : (Bool -> msg) -> Sub msg


port popupCallback : (Bool -> msg) -> Sub msg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ mapCallback MapResponse
        , popupCallback PopupResponse
        ]
