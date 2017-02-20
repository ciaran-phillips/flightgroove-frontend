module API.Decoders.DateGrid exposing (dateGrid)

import Json.Decode exposing (Decoder, maybe, int, string, list, map2, map4, field)
import API.Types.DateGrid exposing (DateGrid, DateGridRow, DateGridCell)


dateGrid : Decoder DateGrid
dateGrid =
    map2 DateGrid
        (field "columnHeaders" (list (maybe string)))
        (field "rows" (list dateGridRowDecoder))


dateGridRowDecoder : Decoder DateGridRow
dateGridRowDecoder =
    map2 DateGridRow
        (field "rowHeader" string)
        (field "cells" (list (maybe dateGridCellDecoder)))


dateGridCellDecoder : Decoder DateGridCell
dateGridCellDecoder =
    map4 DateGridCell
        (field "priceCredits" int)
        (field "priceDisplay" string)
        (field "outboundDate" string)
        (field "inboundDate" string)
