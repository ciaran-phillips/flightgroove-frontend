module Explorer.Types exposing (..)


type RemoteData err a
    = Empty
    | Loading
    | Success a
    | Failure err
