module UIComponents.Map.Sidebar.SidebarModel exposing (..)

import API.Response as Response
import UIComponents.Types as Types exposing (RemoteData(..))
import API.CostOfLiving as CostOfLiving
import Maybe
import Array
import Http


type alias SidebarModel =
    { dateGrid : RemoteData Http.Error Response.DateGrid
    , gridPosition : GridPosition
    , gridSize : GridSize
    , destination : Response.Airport
    , lowestPrice : String
    , selectedOutboundDate : String
    , selectedInboundDate : String
    , activeTab : Int
    , costOfLivingData : RemoteData Http.Error CostOfLiving.CostOfLiving
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


newSidebarModel : Response.Airport -> String -> String -> String -> SidebarModel
newSidebarModel destination outboundDate inboundDate lowestPrice =
    { dateGrid = Loading
    , gridPosition = { x = 0, y = 0 }
    , gridSize = { rows = 0, columns = 0 }
    , destination = destination
    , selectedOutboundDate = outboundDate
    , selectedInboundDate = inboundDate
    , lowestPrice = lowestPrice
    , activeTab = 0
    , costOfLivingData = Empty
    , sidebarVisible = True
    }


getGridSize : Response.DateGrid -> GridSize
getGridSize grid =
    { rows = List.length grid.columnHeaders
    , columns = List.length grid.rows
    }


getTripDatesFromGrid : Int -> Int -> Response.DateGrid -> ( Maybe String, Maybe String )
getTripDatesFromGrid row col grid =
    let
        outboundDate =
            getOutboundDateFromGrid col grid

        inboundDate =
            getInboundDateFromGrid row grid
    in
        ( outboundDate, inboundDate )


getInboundDateFromGrid : Int -> Response.DateGrid -> Maybe String
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


getOutboundDateFromGrid : Int -> Response.DateGrid -> Maybe String
getOutboundDateFromGrid colIndex grid =
    Maybe.withDefault Nothing <|
        Array.get colIndex (Array.fromList grid.columnHeaders)
