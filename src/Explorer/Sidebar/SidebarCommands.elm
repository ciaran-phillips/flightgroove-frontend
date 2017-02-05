module Explorer.Sidebar.SidebarCommands exposing (..)

import API.Skyscanner as API
import Explorer.Sidebar.SidebarMessages exposing (..)
import Explorer.Messages exposing (Msg(SidebarTag))
import Explorer.Model exposing (Model)
import Task
import API.CostOfLiving as CostOfLiving
import API.Activities as Activities


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


getCostOfLivingData : String -> Cmd Msg
getCostOfLivingData cityId =
    Task.perform (SidebarTag << CostOfLivingFetchFailure) (SidebarTag << CostOfLivingFetchSuccess) <|
        CostOfLiving.getData { cityId = cityId }


getActivities : String -> Cmd Msg
getActivities query =
    Task.perform (SidebarTag << ActivitiesFetchFailure) (SidebarTag << ActivitiesFetchSuccess) <|
        Activities.getData { locationQuery = query }
