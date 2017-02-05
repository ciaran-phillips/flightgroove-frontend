port module Explorer.Ports exposing (..)

import Explorer.MapComp.MapTypes exposing (PopupDefinition)


-- Commands


port map : String -> Cmd msg


port popup : PopupDefinition -> Cmd msg


port clearPopups : Bool -> Cmd msg



-- Suscriptions


port mapCallback : (Bool -> msg) -> Sub msg


port popupCallback : (Bool -> msg) -> Sub msg


port popupSelected : (String -> msg) -> Sub msg
