module Model exposing (..)

import Explorer.Model as ExplorerModel
import Explorer.Filters.Filters as Filters


type alias Model =
    { explorerModel : ExplorerModel.Model
    , menuDrawerOpen : Bool
    }
