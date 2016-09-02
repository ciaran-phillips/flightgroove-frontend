module UIComponents.Filters exposing (..)

import Material exposing (..)
import Material.Textfield as Textfield
import Html exposing (..)
import Html.App
import Html.Attributes exposing (class)
import Autocomplete
import String


type alias Model =
    { mdl : Material.Model
    , locationId : String
    , airport : String
    , autoState : Autocomplete.State
    , airportList : List Location
    , numOptionsDisplayed : Int
    , showMenu : Bool
    }


type alias Location =
    { airportId : String
    , name : String
    }


init : ( Model, Cmd Msg )
init =
    ( model, Cmd.none )


model : Model
model =
    { mdl = Material.model
    , locationId = ""
    , airport = ""
    , airportList = getAirportList
    , autoState = Autocomplete.empty
    , numOptionsDisplayed = 10
    , showMenu = False
    }


type Msg
    = Mdl (Material.Msg Msg)
    | ChangeAirport String
    | AutocompleteMsg Autocomplete.Msg
    | SelectAirport String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeAirport txt ->
            ( { model | airport = txt, showMenu = True }, Cmd.none )

        SelectAirport airport ->
            ( { model | locationId = airport, showMenu = False, airport = displayText airport }, Cmd.none )

        Mdl msg' ->
            Material.update msg' model

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


displayText airport =
    let
        selectedAirport =
            List.filter (\n -> n.airportId == airport) model.airportList
                |> List.head
    in
        case selectedAirport of
            Nothing ->
                ""

            Just selectedAirport ->
                selectedAirport.name


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


getAirportList : List Location
getAirportList =
    [ { airportId = "dub"
      , name = "Dublin"
      }
    , { airportId = "dubr"
      , name = "Dubrovnik"
      }
    , { airportId = "Dusseldorf"
      , name = "Dusseldorf"
      }
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


filterLocations : String -> List Location -> List Location
filterLocations query locations =
    let
        transformedQuery =
            String.toLower query

        filterFunction =
            matchesLocation transformedQuery
    in
        List.filter filterFunction locations


matchesLocation : String -> Location -> Bool
matchesLocation lowercaseQuery location =
    String.toLower location.name
        |> String.contains lowercaseQuery


updateConfig : Autocomplete.UpdateConfig Msg Location
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
        , toId = .airportId
        , separateSelections = True
        }


viewConfig : Autocomplete.ViewConfig Location
viewConfig =
    Autocomplete.viewConfig
        { toId = \airport -> airport.airportId
        , ul = [ class "autocomplete-list" ]
        , li = listItem
        }


listItem :
    Autocomplete.KeySelected
    -> Autocomplete.MouseSelected
    -> Location
    -> Autocomplete.HtmlDetails Never
listItem keySelected mouseSelected location =
    if keySelected then
        { attributes = [ class "autocomplete-item autocomplete-item--key" ]
        , children = [ Html.text location.name ]
        }
    else if mouseSelected then
        { attributes = [ class "autocomplete-item autocomplete-item--mouse" ]
        , children = [ Html.text location.name ]
        }
    else
        { attributes = [ class "autocomplete-item" ]
        , children = [ Html.text location.name ]
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.map AutocompleteMsg Autocomplete.subscription
