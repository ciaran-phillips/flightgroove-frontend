module Messages exposing (..)

import Explorer.Messages as ExplorerMessages


type Msg
    = ExplorerMsg ExplorerMessages.Msg
    | ToggleMenuDrawer
