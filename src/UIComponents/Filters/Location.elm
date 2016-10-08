module UIComponents.Filters.Location
    exposing
        ( Model
        , Msg
        , model
        , initialCmd
        , update
        , view
        , subscriptions
        , getSelectedLocation
        , viewAirportName
        )

-- Core Imports

import Html exposing (..)
import Html.App
import Html.Attributes exposing (class, placeholder, value)
import Html.Events exposing (onInput)
import Http
import Task
import String


-- THird party packages

import Material exposing (..)
import Material.Textfield as Textfield
import Autocomplete


-- Custom Modules

import API.Response as Response
import API.Skyscanner as API
import API.GetUserLocation as GetUserLocation
import UIComponents.Types as Types exposing (RemoteData(..))


type alias Model =
    { mdl : Material.Model
    , autocompleteState : Autocomplete.State
    , chosenLocationId : Maybe String
    , displayText : String
    , locationList : Response.Locations
    , userLocation : RemoteData Http.Error Response.LocationSuggestion
    , maxLocationsDisplayed : Int
    , showLocationsDropdown : Bool
    }


type Msg
    = InputQuery String
    | SelectLocation String
    | FetchSuccess Response.Response
    | FetchFail Http.Error
    | GetUserLocationFailure Http.Error
    | GetUserLocationSuccess Response.Response
    | AutocompleteMsg Autocomplete.Msg
    | Mdl (Material.Msg Msg)


model : Model
model =
    { mdl = Material.model
    , autocompleteState = Autocomplete.empty
    , chosenLocationId = Nothing
    , displayText = ""
    , locationList = []
    , userLocation = Empty
    , maxLocationsDisplayed = 10
    , showLocationsDropdown = False
    }


initialCmd : Cmd Msg
initialCmd =
    Task.perform GetUserLocationFailure GetUserLocationSuccess GetUserLocation.getUserLocation


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        -- MDL Boilerplate
        Mdl msg' ->
            Material.update msg' model

        InputQuery txt ->
            if String.isEmpty txt then
                ( { model | displayText = txt, showLocationsDropdown = False, locationList = [] }, Cmd.none )
            else
                ( { model | displayText = txt, showLocationsDropdown = True }, updateAirportList txt )

        SelectLocation locationId ->
            ( { model
                | chosenLocationId = Just locationId
                , showLocationsDropdown = False
                , displayText = formattedLocationNameFromId model.locationList locationId
              }
            , Cmd.none
            )

        FetchSuccess response ->
            case response of
                Response.LocationsResponse locations ->
                    ( { model
                        | locationList = locations
                        , autocompleteState =
                            Autocomplete.resetToFirstItem
                                updateConfig
                                locations
                                model.maxLocationsDisplayed
                                model.autocompleteState
                      }
                    , Cmd.none
                    )

                Response.RoutesResponse routes ->
                    model ! []

                Response.DateGridResponse result ->
                    model ! []

        FetchFail error ->
            model ! []

        GetUserLocationSuccess response ->
            case response of
                Response.LocationsResponse locations ->
                    ( { model
                        | locationList = locations
                        , displayText = Maybe.withDefault "default" <| firstLocationName locations
                        , chosenLocationId = firstLocationId locations
                        , autocompleteState =
                            Autocomplete.resetToFirstItem
                                updateConfig
                                locations
                                model.maxLocationsDisplayed
                                model.autocompleteState
                      }
                    , Cmd.none
                    )

                _ ->
                    model ! []

        GetUserLocationFailure err ->
            ( { model | userLocation = Failure <| Debug.log "failed to load user location" err }, Cmd.none )

        AutocompleteMsg msg ->
            updateAutocomplete msg model


getSelectedLocation : Model -> Maybe String
getSelectedLocation model =
    model.chosenLocationId


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map AutocompleteMsg Autocomplete.subscription


view : Model -> Html Msg
view model =
    div [ class "dropdown-container" ]
        [ viewAirportSelector model
        , viewAutocomplete model
        ]


viewAirportName : Model -> String
viewAirportName model =
    if String.isEmpty model.displayText then
        "unset"
    else
        model.displayText



-- Unexposed Functions


updateAutocomplete : Autocomplete.Msg -> Model -> ( Model, Cmd Msg )
updateAutocomplete msg model =
    let
        ( newAutoState, maybeMsg ) =
            Autocomplete.update updateConfig msg model.maxLocationsDisplayed model.autocompleteState model.locationList

        newModel =
            { model | autocompleteState = newAutoState }
    in
        case maybeMsg of
            Nothing ->
                newModel ! []

            Just outMsg ->
                update outMsg newModel


updateAirportList : String -> Cmd Msg
updateAirportList query =
    Task.perform FetchFail FetchSuccess <|
        API.callLocations { query = query }


formattedLocationNameFromId : Response.Locations -> String -> String
formattedLocationNameFromId airportList chosenId =
    let
        chosenLocation =
            List.filter (\n -> n.placeId == chosenId) airportList
                |> List.head
    in
        case chosenLocation of
            Nothing ->
                "not found - "

            Just chosenLocation ->
                formatLocationName chosenLocation


firstLocationName : Response.Locations -> Maybe String
firstLocationName locations =
    case List.head locations of
        Nothing ->
            Nothing

        Just location ->
            Just <| formatLocationName location


firstLocationId : Response.Locations -> Maybe String
firstLocationId locations =
    case List.head locations of
        Nothing ->
            Nothing

        Just location ->
            Just location.placeId


formatLocationName : Response.LocationSuggestion -> String
formatLocationName location =
    location.placeName
        ++ ", "
        ++ location.countryName
        ++ " ("
        ++ formatId location.placeId
        ++ ")"


formatId : String -> String
formatId idString =
    Maybe.withDefault "" <|
        List.head <|
            String.split "-" idString


viewAirportSelector : Model -> Html Msg
viewAirportSelector model =
    div []
        [ input [ onInput InputQuery, value model.displayText, placeholder "Dublin, London etc.." ] []
        ]


viewAutocomplete : Model -> Html Msg
viewAutocomplete model =
    let
        filteredList =
            model.locationList
    in
        if model.showLocationsDropdown then
            Html.App.map AutocompleteMsg <|
                Autocomplete.view viewConfig model.maxLocationsDisplayed model.autocompleteState filteredList
        else
            div [] []


filterLocations : String -> Response.Locations -> Response.Locations
filterLocations query locations =
    let
        transformedQuery =
            String.toLower query

        filterFunction =
            matchesLocation transformedQuery
    in
        List.filter filterFunction locations


matchesLocation : String -> Response.LocationSuggestion -> Bool
matchesLocation lowercaseQuery location =
    String.toLower location.placeName
        |> String.contains lowercaseQuery


updateConfig : Autocomplete.UpdateConfig Msg Response.LocationSuggestion
updateConfig =
    Autocomplete.updateConfig
        { onKeyDown =
            \code maybeId ->
                if code == 38 || code == 40 then
                    Nothing
                else if code == 13 then
                    Maybe.map SelectLocation maybeId
                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| SelectLocation id
        , toId = .placeId
        , separateSelections = False
        }


viewConfig : Autocomplete.ViewConfig Response.LocationSuggestion
viewConfig =
    Autocomplete.viewConfig
        { toId = \airport -> airport.placeId
        , ul = [ class "autocomplete-list" ]
        , li = listItem
        }


listItem :
    Autocomplete.KeySelected
    -> Autocomplete.MouseSelected
    -> Response.LocationSuggestion
    -> Autocomplete.HtmlDetails Never
listItem keySelected mouseSelected location =
    if keySelected then
        { attributes = [ class "autocomplete-item autocomplete-item--key" ]
        , children = [ Html.text <| formatLocationName location ]
        }
    else if mouseSelected then
        { attributes = [ class "autocomplete-item autocomplete-item--mouse" ]
        , children = [ Html.text <| formatLocationName location ]
        }
    else
        { attributes = [ class "autocomplete-item" ]
        , children = [ Html.text <| formatLocationName location ]
        }
