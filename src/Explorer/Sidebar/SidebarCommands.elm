module Explorer.Sidebar.SidebarCommands exposing (..)

import Explorer.Sidebar.SidebarMessages exposing (..)
import Explorer.Messages exposing (Msg(SidebarTag))
import Explorer.Model exposing (Model)
import Task
import API.Calls as API


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
            API.getDateGrid
                { origin = model.criteria.locationId
                , destination = dest
                , outboundDate = model.criteria.outboundDate
                , inboundDate = model.criteria.inboundDate
                }


getCostOfLivingData : String -> Cmd Msg
getCostOfLivingData cityId =
    Task.perform (SidebarTag << CostOfLivingFetchFailure) (SidebarTag << CostOfLivingFetchSuccess) <|
        API.getCostOfLiving { cityId = cityId }


getActivities : String -> Cmd Msg
getActivities query =
    Task.perform (SidebarTag << ActivitiesFetchFailure) (SidebarTag << ActivitiesFetchSuccess) <|
        API.getActivities { locationQuery = query }
