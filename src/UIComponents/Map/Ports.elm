port module UIComponents.Map.Ports exposing (..)

import UIComponents.Map.MapComp.MapTypes exposing (PopupDefinition)


-- Commands


port map : String -> Cmd msg


port popup : PopupDefinition -> Cmd msg


port clearPopups : Bool -> Cmd msg



-- Suscriptions


port mapCallback : (Bool -> msg) -> Sub msg


port popupCallback : (Bool -> msg) -> Sub msg


port popupSelected : (String -> msg) -> Sub msg
