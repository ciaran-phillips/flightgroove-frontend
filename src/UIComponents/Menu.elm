module UIComponents.Menu exposing (..)

import Html exposing (..)
import Html.App
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import UIComponents.Lib.Dropdown as Dropdown
import Mouse


type CategoryFilter
    = CatOne
    | CatTwo
    | CatThree
    | CatFour


type SizeFilter
    = SizeOne
    | SizeTwo
    | SizeThree
    | SizeFour


type Msg
    = CategoryMsg (Dropdown.Msg CategoryFilter)
    | SizeMsg (Dropdown.Msg SizeFilter)


type alias Model =
    { categoryDropdown : Dropdown.Model
    , currentCategory : String
    , sizeDropdown : Dropdown.Model
    , currentSize : String
    }


initialModel : Model
initialModel =
    { categoryDropdown = Dropdown.initialModel
    , currentCategory = "no category chosen"
    , sizeDropdown = Dropdown.initialModel
    , currentSize = "no size chosen"
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoryMsg (Dropdown.Navigate category) ->
            let
                ( newModel, newCmd ) =
                    Dropdown.update (Dropdown.Navigate category) model.categoryDropdown

                newCategory =
                    getCategory category
            in
                ( { model | categoryDropdown = newModel, currentCategory = newCategory }, Cmd.none )

        SizeMsg (Dropdown.Navigate sizeMsg) ->
            let
                ( newModel, newCmd ) =
                    Dropdown.update (Dropdown.Navigate sizeMsg) model.sizeDropdown

                newSize =
                    getSize sizeMsg
            in
                ( { model | sizeDropdown = newModel, currentSize = newSize }, Cmd.none )

        CategoryMsg dropdownMsg ->
            let
                ( newModel, newCmd ) =
                    Dropdown.update dropdownMsg model.categoryDropdown
            in
                ( { model | categoryDropdown = newModel }, Cmd.none )

        SizeMsg dropdownMsg ->
            let
                ( newModel, newCmd ) =
                    Dropdown.update dropdownMsg model.sizeDropdown
            in
                ( { model | sizeDropdown = newModel }, Cmd.none )


view : Model -> Html Msg
view model =
    let
        categoryDropdown =
            Dropdown.view categoryList model.categoryDropdown
                |> Html.App.map CategoryMsg

        sizeDropdown =
            Dropdown.view sizeList model.sizeDropdown
                |> Html.App.map SizeMsg
    in
        div [ class "dropdowns" ]
            [ div [] [ text model.currentCategory ]
            , div [] [ categoryDropdown ]
            , div [] [ text model.currentSize ]
            , div [] [ sizeDropdown ]
            ]


subscriptions : Model -> Sub (Msg)
subscriptions model =
    Sub.batch
        [ Sub.map CategoryMsg <|
            Dropdown.subscriptions model.categoryDropdown
        , Sub.map SizeMsg <|
            Dropdown.subscriptions model.sizeDropdown
        ]


categoryList : List (Html (Dropdown.Msg CategoryFilter))
categoryList =
    let
        buildListElem =
            \n ->
                li [] [ a [ onClick (Dropdown.Navigate n) ] [ text <| getCategory n ] ]
    in
        List.map buildListElem [ CatOne, CatTwo, CatThree, CatFour ]


sizeList : List (Html (Dropdown.Msg SizeFilter))
sizeList =
    let
        buildListElem =
            \n ->
                li [] [ a [ onClick (Dropdown.Navigate n) ] [ text <| getSize n ] ]
    in
        List.map buildListElem [ SizeOne, SizeTwo, SizeThree, SizeFour ]


getCategory : CategoryFilter -> String
getCategory category =
    case category of
        CatOne ->
            "Category One"

        CatTwo ->
            "Category Three"

        CatThree ->
            "Category Three"

        CatFour ->
            "Category Four"


getSize : SizeFilter -> String
getSize s =
    case s of
        SizeOne ->
            "Size One"

        SizeTwo ->
            "Size Two"

        SizeThree ->
            "Size Three"

        SizeFour ->
            "Size Four"
