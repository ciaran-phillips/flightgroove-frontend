port module UIComponents.Map.Ports exposing (..)

import UIComponents.Map.Model exposing (PopupDefinition)


-- Commands


port map : String -> Cmd msg


port popup : PopupDefinition -> Cmd msg



-- Suscriptions


port mapCallback : (Bool -> msg) -> Sub msg


port popupCallback : (Bool -> msg) -> Sub msg


port popupSelected : (String -> msg) -> Sub msg
