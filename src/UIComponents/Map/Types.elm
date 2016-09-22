module UIComponents.Map.Types exposing (..)


type alias PopupDefinition =
    ( String, Float, Float, String )


type alias GridPosition =
    { x : Int
    , y : Int
    }


type RemoteData a
    = Empty
    | Loading
    | Success a
    | Failure a
