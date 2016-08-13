module Main exposing (..)


import Html exposing (..)
import Html.Attributes exposing (class)
import Html.App


type alias Model =
  String


type Msg =
  NoOp


init : ( Model, Cmd Msg)
init =
  ("Hello World", Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model -> Html Msg
view model =
  div [ class "container" ] [
    div [] [
      h1 [] [
        text model
      ]
    ]
  ]


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
  ( model, Cmd.none )


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
