port module UIComponents.Map exposing (..)

import Html exposing (..)
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)
import Http
import Task
import String
import API.Skyscanner as API
import API.Response as Response


type Msg
    = SetupMap
    | MapResponse Bool
    | PopupResponse Bool
    | FetchData
    | FetchSuccess Response.Response
    | FetchFail Http.Error
    | ChangeCriteria String


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , criteria : String
    }


type alias PopupDefinition =
    ( Float, Float, String )


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    , criteria = ""
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

        ChangeCriteria newCriteria ->
            if newCriteria == model.criteria then
                ( model, Cmd.none )
            else
                ( { model | criteria = newCriteria }, getApiData newCriteria )

        FetchData ->
            ( model, getApiData "DUB-sky" )

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


getApiData : String -> Cmd Msg
getApiData location =
    Task.perform FetchFail FetchSuccess <|
        if String.isEmpty location then
            getRoutes "DUB-sky"
        else
            getRoutes location


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


getRoutes : String -> Task.Task Http.Error Response.Response
getRoutes location =
    API.callRoutes
        { origin = location
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
