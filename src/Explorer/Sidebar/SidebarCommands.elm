module Explorer.Sidebar.SidebarCommands exposing (..)

import Explorer.Sidebar.SidebarMessages exposing (..)
import Explorer.Messages exposing (Msg(SidebarTag))
import Explorer.Model exposing (Model)
import API.Calls as API
import Http


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
        Http.send (SidebarTag << GridFetchUpdate) <|
            API.getDateGrid
                { origin = model.criteria.locationId
                , destination = dest
                , outboundDate = model.criteria.outboundDate
                , inboundDate = model.criteria.inboundDate
                }


getCostOfLivingData : String -> Cmd Msg
getCostOfLivingData cityId =
    Http.send (SidebarTag << CostOfLivingFetchUpdate) <|
        API.getCostOfLiving { cityId = cityId }


getActivities : String -> Cmd Msg
getActivities query =
    Http.send (SidebarTag << ActivitiesFetchUpdate) <|
        API.getActivities { locationQuery = query }
