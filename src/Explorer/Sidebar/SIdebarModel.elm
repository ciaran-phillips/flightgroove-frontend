module Explorer.Sidebar.SidebarModel exposing (..)

import Explorer.Types as Types exposing (RemoteData(..))
import API.GetCostOfLiving.Types as CostOfLivingTypes
import API.GetActivities.Types as ActivitiesTypes
import API.LocationTypes as LocationTypes
import API.DateGridTypes as DateGridTypes
import Maybe
import Array
import Http


type alias SidebarModel =
    { dateGrid : RemoteData Http.Error DateGridTypes.DateGrid
    , gridPosition : GridPosition
    , gridSize : GridSize
    , destination : LocationTypes.Airport
    , multipleOrigins : Bool
    , lowestPrice : String
    , selectedOutboundDate : String
    , selectedInboundDate : String
    , activeTab : Int
    , costOfLivingData : RemoteData Http.Error CostOfLivingTypes.CostOfLiving
    , activities : RemoteData Http.Error ActivitiesTypes.Activities
    , sidebarVisible : Bool
    }


type alias GridSize =
    { rows : Int
    , columns : Int
    }


type alias GridPosition =
    { x : Int
    , y : Int
    }


type alias CellData =
    { x : Int
    , y : Int
    , outboundDate : String
    , inboundDate : String
    }


newSidebarModel : LocationTypes.Airport -> String -> String -> String -> Bool -> SidebarModel
newSidebarModel destination outboundDate inboundDate lowestPrice multipleOrigins =
    { dateGrid = Loading
    , gridPosition = { x = 0, y = 0 }
    , gridSize = { rows = 0, columns = 0 }
    , multipleOrigins = multipleOrigins
    , destination = destination
    , selectedOutboundDate = outboundDate
    , selectedInboundDate = inboundDate
    , lowestPrice = lowestPrice
    , activeTab = 0
    , costOfLivingData = Empty
    , activities = Empty
    , sidebarVisible = True
    }


getGridSize : DateGridTypes.DateGrid -> GridSize
getGridSize grid =
    { rows = List.length grid.columnHeaders
    , columns = List.length grid.rows
    }


getTripDatesFromGrid : Int -> Int -> DateGridTypes.DateGrid -> ( Maybe String, Maybe String )
getTripDatesFromGrid row col grid =
    let
        outboundDate =
            getOutboundDateFromGrid col grid

        inboundDate =
            getInboundDateFromGrid row grid
    in
        ( outboundDate, inboundDate )


getInboundDateFromGrid : Int -> DateGridTypes.DateGrid -> Maybe String
getInboundDateFromGrid rowIndex grid =
    let
        inboundRow =
            (Array.get rowIndex (Array.fromList grid.rows))
    in
        case inboundRow of
            Nothing ->
                Nothing

            Just row ->
                Just row.rowHeader


getOutboundDateFromGrid : Int -> DateGridTypes.DateGrid -> Maybe String
getOutboundDateFromGrid colIndex grid =
    Maybe.withDefault Nothing <|
        Array.get colIndex (Array.fromList grid.columnHeaders)
