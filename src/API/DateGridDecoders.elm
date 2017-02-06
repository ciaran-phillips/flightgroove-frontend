module API.DateGridDecoders exposing (dateGrid)

import Json.Decode exposing (Decoder, maybe, int, string, list, object2, object4, (:=))
import API.DateGridTypes exposing (DateGrid, DateGridRow, DateGridCell)


dateGrid : Decoder DateGrid
dateGrid =
    object2 DateGrid
        ("columnHeaders" := list (maybe string))
        ("rows" := list dateGridRowDecoder)


dateGridRowDecoder : Decoder DateGridRow
dateGridRowDecoder =
    object2 DateGridRow
        ("rowHeader" := string)
        ("cells" := list (maybe dateGridCellDecoder))


dateGridCellDecoder : Decoder DateGridCell
dateGridCellDecoder =
    object4 DateGridCell
        ("priceCredits" := int)
        ("priceDisplay" := string)
        ("outboundDate" := string)
        ("inboundDate" := string)
