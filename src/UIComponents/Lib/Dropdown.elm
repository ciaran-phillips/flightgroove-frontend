module UIComponents.Lib.Dropdown exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Mouse

type Msg a =
  Toggle
  | MouseMsg Mouse.Position
  | Navigate a


type alias Model =
  { open : Bool }


initialModel : Model
initialModel =
  { open = False }


update : Msg a -> Model ->  ( Model, Cmd Msg )
update msg model =
  case msg of
    Toggle ->
      ( { model | open = not model.open }, Cmd.none )
    Navigate msg ->
      ( { model | open = model.open }, Cmd.none )
    MouseMsg pos ->
      ( { model | open = False}, Cmd.none )


view : List (Html (Msg a)) -> Model -> Html (Msg a)
view links model =
  let
    wrapperClass = if model.open then "open" else ""
  in
    div [ class ("dropdown " ++ wrapperClass) , onClick Toggle]
      [ button []
        [ text "Dropdown"
        , span [ class "caret" ] []
        ]
      , ul [ class "dropdown-menu" ] links
      ]

subscriptions : Model -> Sub (Msg a)
subscriptions model =
  if model.open then
    Mouse.clicks MouseMsg
  else
    Sub.none
