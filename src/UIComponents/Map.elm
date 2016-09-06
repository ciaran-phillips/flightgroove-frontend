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
import UIComponents.Types exposing (FilterCriteria)


type Msg
    = SetupMap
    | MapResponse Bool
    | PopupResponse Bool
    | FetchData
    | FetchSuccess Response.Response
    | FetchFail Http.Error
    | ChangeCriteria FilterCriteria


type alias Model =
    { mapActive : Bool
    , mapData : Response.Routes
    , criteria : FilterCriteria
    }


type alias PopupDefinition =
    ( Float, Float, String )


initialModel : Model
initialModel =
    { mapActive = False
    , mapData = defaultMapData
    , criteria = defaultCriteria
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
            ( model, getApiData defaultCriteria )

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
        [ div [ class "map-wrapper" ] [ div [ id "map" ] [] ] ]


mapId : String
mapId =
    "map"


getApiData : FilterCriteria -> Cmd Msg
getApiData criteria =
    Task.perform FetchFail FetchSuccess <|
        if String.isEmpty criteria.locationId then
            getRoutes criteria
        else
            getRoutes criteria


defaultCriteria : FilterCriteria
defaultCriteria =
    { locationId = "DUB-sky"
    , inboundDate = "2016-09"
    , outboundDate = "2016-09"
    }


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


getRoutes : FilterCriteria -> Task.Task Http.Error Response.Response
getRoutes criteria =
    API.callRoutes
        { origin = criteria.locationId
        , destination = "anywhere"
        , outboundDate = criteria.outboundDate
        , inboundDate = criteria.inboundDate
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
