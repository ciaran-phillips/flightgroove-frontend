module UIComponents.Map.Sidebar.SidebarCommands exposing (..)

import API.Skyscanner as API
import UIComponents.Map.Sidebar.SidebarMessages exposing (..)
import UIComponents.Map.Messages exposing (Msg(SidebarTag))
import UIComponents.Map.Model exposing (Model)
import Task


getFullMonthData : Model -> Cmd Msg
getFullMonthData model =
    let
        dest =
            case model.selectedDestination of
                Nothing ->
                    "PRG-sky"

                Just dest ->
                    dest
    in
        Task.perform (SidebarTag << GridFetchFail) (SidebarTag << GridFetchSuccess) <|
            API.callDates
                { origin = model.criteria.locationId
                , destination = dest
                , outboundDate = "2016-10"
                , inboundDate = "2016-10"
                }
