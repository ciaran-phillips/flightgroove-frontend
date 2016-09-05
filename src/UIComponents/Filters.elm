module UIComponents.Filters exposing (..)

import Material exposing (..)
import Material.Textfield as Textfield
import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Autocomplete
import String
import API.Response as Response
import API.Skyscanner as API
import Http
import Task
import Debug


type alias Model =
    { mdl : Material.Model
    , locationId : String
    , airport : String
    , autoState : Autocomplete.State
    , airportList : Response.Locations
    , numOptionsDisplayed : Int
    , showMenu : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { mdl = Material.model
    , locationId = ""
    , airport = ""
    , airportList = []
    , autoState = Autocomplete.empty
    , numOptionsDisplayed = 10
    , showMenu = False
    }


type Msg
    = Mdl (Material.Msg Msg)
    | ChangeAirport String
    | AutocompleteMsg Autocomplete.Msg
    | SelectAirport String
    | FetchFail Http.Error
    | FetchSuccess Response.Response


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeAirport txt ->
            if String.isEmpty txt then
                ( { model | airport = txt, showMenu = False, airportList = [] }, Cmd.none )
            else
                ( { model | airport = txt, showMenu = True }, updateAirportList txt )

        SelectAirport placeId ->
            ( { model | locationId = placeId, showMenu = False, airport = formattedLocationNameFromId model.airportList placeId }, Cmd.none )

        Mdl msg' ->
            Material.update msg' model

        FetchFail error ->
            let
                x =
                    Debug.log "error is " error
            in
                ( model, Cmd.none )

        FetchSuccess response ->
            case response of
                Response.LocationsResponse locations ->
                    ( { model | airportList = locations }, Cmd.none )

                Response.RoutesResponse routes ->
                    model ! []

        AutocompleteMsg msg ->
            let
                ( newAutoState, maybeMsg ) =
                    Autocomplete.update updateConfig msg model.autoState model.airportList model.numOptionsDisplayed

                newModel =
                    { model | autoState = newAutoState }
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


formatLocationName location =
    location.placeName
        ++ ", "
        ++ location.countryName
        ++ " ("
        ++ location.placeId
        ++ ")"


getCriteria model =
    model.locationId


view : Model -> Html Msg
view model =
    div [ class "dropdown-container" ]
        [ viewAirportSelector model
        , viewAutocomplete model
        ]


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
            , Textfield.value model.airport
            ]
        ]


viewAutocomplete : Model -> Html Msg
viewAutocomplete model =
    let
        filteredList =
            filterLocations model.airport model.airportList
    in
        if model.showMenu then
            Html.App.map AutocompleteMsg <|
                Autocomplete.view viewConfig model.numOptionsDisplayed model.autoState filteredList
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
                    Maybe.map SelectAirport maybeId
                else
                    Nothing
        , onTooLow = Nothing
        , onTooHigh = Nothing
        , onMouseEnter = \_ -> Nothing
        , onMouseLeave = \_ -> Nothing
        , onMouseClick = \id -> Just <| SelectAirport id
        , toId = .placeId
        , separateSelections = True
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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map AutocompleteMsg Autocomplete.subscription
