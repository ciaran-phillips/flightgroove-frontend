module Messages exposing (..)

import Explorer.Messages as ExplorerMessages
import Explorer.Filters.Filters as Filters


type Msg
    = ExplorerMsg ExplorerMessages.Msg
    | FilterMsg Filters.Msg
    | ToggleFilterDrawer
