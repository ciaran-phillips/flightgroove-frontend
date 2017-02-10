module Explorer.Map.MapMessages exposing (..)


type MapMsg
    = MapResponse Bool
    | PopupResponse Bool
    | SelectDestination String
